require "graphql/client"
require "graphql/client/http"

class PaymentHistory::ApiImporter
  include ShopifyPartnerAPI

  THROTTLE_MIN_TIME_PER_CALL = 0.3

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

  def initialize(user:)
    @user = user
    @batch_of_payments = []
  end

  attr_reader :user

  def import!
    user.clear_old_payments
    import_new_payments
  rescue => error
    handle_import_error(error)
    raise error
  end

  private

  def import_new_payments
    cursor = ""
    has_next_page = true
    created_at_min = user.calculate_from_date.iso8601 # ISO-8601
    throttle_start_time = Time.zone.now

    while has_next_page == true
      transactions = []
      throttle_start_time = throttle(throttle_start_time)

      results = fetch_from_api(cursor, created_at_min)
      return if results.data.nil?

      transactions = results.data.transactions.edges
      Rails.logger.info("Number of Transactions: " + transactions.size.to_s)
      has_next_page = results.data.transactions.page_info.has_next_page
      cursor = results.data.transactions.edges.last.cursor

      transactions.each do |transaction|
        payment = new_payment(transaction.node)
        @batch_of_payments << payment if payment.present?
      end

      PaymentHistory.import(@batch_of_payments, validate: false, no_returning: true)
      @batch_of_payments = []
    end
  end

  private

  def fetch_from_api(cursor, created_at_min)
    results = ShopifyPartnerAPI.client.query(
      Graphql::TransactionsQuery,
      variables: {createdAtMin: created_at_min, cursor: cursor},
      context: {access_token: user.partner_api_access_token, organization_id: user.partner_api_organization_id}
    )
    Rails.logger.info(results.inspect)
    raise StandardError.new(results.errors.messages.map { |k, v| "#{k}=#{v}" }.join("&")) if results.errors.any?
    results
  end

  def new_payment(node)
    created_at = Date.parse(node.created_at)
    return nil if created_at <= user.calculate_from_date

    charge_type = lookup_charge_type(node.__typename)
    return nil if charge_type.nil?

    payment = PaymentHistory.new(
      user_id: user.id,
      charge_type: charge_type,
      payment_date: created_at
    )

    payment.revenue = case node.__typename
    when "ReferralAdjustment", "ReferralTransaction"
      node.amount.amount
    else
      node.net_amount.amount
    end

    payment.app_title = case node.__typename
    when "ReferralAdjustment", "ReferralTransaction", "ServiceSale", "ServiceSaleAdjustment"
      PaymentHistory::UNKNOWN_APP_TITLE
    when "ThemeSaleAdjustment", "ThemeSale"
      node.theme.name
    else
      node.app.name
    end

    payment.shop = case node.__typename
    when "ReferralTransaction"
      node.shop_non_nullable.myshopify_domain
    else
      node.shop&.myshopify_domain
    end
    return nil if payment.shop.nil?

    payment
  end

  def throttle(start_time)
    stop_time = Time.zone.now
    processing_duration = stop_time - start_time
    wait_time = (THROTTLE_MIN_TIME_PER_CALL - processing_duration).round(1)
    Rails.logger.info("THROTTLING: #{wait_time}")
    sleep wait_time if wait_time > 0.0
    Time.zone.now
  end

  def lookup_charge_type(api_type)
    charge_type = API_REVENUE_TYPES.find { |_key, value| value.include?(api_type) }&.first
    if charge_type == "usage_revenue"
      charge_type = user.count_usage_charges_as_recurring == true ? "recurring_revenue" : "onetime_revenue"
    end
    charge_type
  end

  def handle_import_error(error)
    user.update(
      import: "Failed",
      import_status: 100,
      partner_api_errors: "Error importing your data: #{error.message} - Please check your Account connection settings"
    )
    # Resque swallows errors, so we need to log them here
    Rails.logger.error("Error importing API: #{error.message}")
    Rails.logger.error(error.backtrace.join("\n"))
  end
end
