require "shopify_partner_api"
require "graphql/client"
require "graphql/client/http"

class Import::Adaptor::ShopifyPaymentsApi
  include ShopifyPartnerAPI

  BATCH_SIZE = 100
  MAX_HISTORY = 7.days
  THROTTLE_MIN_TIME_PER_CALL = 0.3.seconds

  API_REVENUE_TYPES = {
    "recurring_revenue" => [
      "AppSubscriptionSale"
    ],
    "onetime_revenue" => [
      "AppOneTimeSale",
      "ServiceSale",
      "ThemeSale"
    ],
    "affiliate_revenue" => [
      "ReferralTransaction"
    ],
    "refund" => [
      "AppCredit",
      "AppSaleAdjustment",
      "AppSaleCredit",
      "ReferralAdjustment",
      "ServiceSaleAdjustment",
      "ThemeSaleAdjustment"
    ],
    "usage_revenue" => [
      "App sale – usage",
      "Usage application fee",
      "AppUsageRecord",
      "AppUsageSale"
    ]
  }.freeze

  def initialize(import:, import_payments_after_date:)
    @import = import
    @import_payments_after_date = import_payments_after_date.strftime("%Y-%m-%dT%H:%M:%S.%L%z")

    @context = import.partner_api_credential.context
    @cursor = ""
    @throttle_start_time = Time.zone.now
  end

  def fetch_payments
    Enumerator.new { |main_enum| stream_payments(main_enum) }
  end

  def batch_size
    BATCH_SIZE
  end

  private

  def stream_payments(main_enum)
    has_next_page = true

    while has_next_page
      @throttle_start_time = throttle(@throttle_start_time)

      results = fetch_from_api(@cursor)
      break if results.data.nil?

      transactions = results.data.transactions.edges
      has_next_page = results.data.transactions.page_info.has_next_page
      @cursor = results.data.transactions.edges.last.cursor

      transactions.each do |transaction|
        main_enum.yield parse(transaction.node)
      end
    end
  end

  def fetch_from_api(cursor)
    results = ShopifyPartnerAPI.client.query(
      Graphql::TransactionsQuery,
      variables: {cursor: cursor, createdAtMin: @import_payments_after_date, first: batch_size},
      context: @context
    )
    handle_error(results.errors) if results.errors.any?
    results
  end

  def parse(node)
    {
      charge_type: charge_type(node),
      payment_date: payment_date(node),
      revenue: revenue(node),
      is_yearly_revenue: is_yearly_revenue(node),
      app_title: app_title(node),
      shop: shop(node),
      # ShopifyPartnerApi does not return shop country
      shop_country: nil
    }
  end

  def charge_type(node)
    API_REVENUE_TYPES.find { |_key, value| value.include?(node.__typename) }&.first
  end

  def payment_date(node)
    Date.parse(node.created_at)
  end

  def revenue(node)
    case node.__typename
    when "ReferralAdjustment", "ReferralTransaction"
      node.amount&.amount&.to_f
    else
      node.net_amount&.amount&.to_f
    end || 0.0
  end

  def is_yearly_revenue(node)
    case node.__typename
    when "AppSubscriptionSale"
      node.billing_interval&.to_s == "ANNUAL"
    else
      false
    end
  end

  def app_title(node)
    case node.__typename
    when "ReferralAdjustment", "ReferralTransaction", "ServiceSale", "ServiceSaleAdjustment"
      Payment::UNKNOWN_APP_TITLE
    when "ThemeSaleAdjustment", "ThemeSale"
      node.theme&.name
    else
      node.app&.name
    end
  end

  def shop(node)
    case node.__typename
    when "ReferralTransaction"
      node.shop_non_nullable&.myshopify_domain
    else
      node.shop&.myshopify_domain
    end
  end

  def throttle(start_time)
    stop_time = Time.zone.now
    processing_duration = stop_time - start_time
    wait_time = (THROTTLE_MIN_TIME_PER_CALL - processing_duration).round(1)
    sleep wait_time if wait_time > 0.0
    Time.zone.now
  end

  def handle_error(api_error)
    error_message = api_error.messages.map { |k, v| "#{k}=#{v}" }.join("&")
    if error_message.include?("Unauthorized") || error_message.include?("Forbidden") || error_message.include?("permissions")
      @import.partner_api_credential.invalidate_with_message!(error_message)
    end
  end
end
