require "zip"
require "graphql/client"
require "graphql/client/http"

class PaymentHistory < ActiveRecord::Base
  include ShopifyPartnerAPI

  TransactionsQuery = ShopifyPartnerAPI.client.parse <<-'GRAPHQL'
    query($createdAtMin: DateTime, $cursor: String) {
      transactions(createdAtMin: $createdAtMin, after: $cursor, first: 100) {
        edges {
          cursor
          node {
            id,
            createdAt,
            # Apps
            ... on AppSubscriptionSale {
              netAmount {
                amount
              },
              app {
                name
              },
              shop {
                myshopifyDomain
              }
            },
            ... on AppOneTimeSale {
              netAmount {
                amount
              },
              app {
                name
              },
              shop {
                myshopifyDomain
              }
            },
            ... on AppSaleAdjustment {
              netAmount {
                amount
              },
              app {
                name
              },
              shop {
                myshopifyDomain
              }
            },
            ... on AppSaleCredit {
              netAmount {
                amount
              },
              app {
                name
              },
              shop {
                myshopifyDomain
              }
            },
            ... on AppUsageSale {
              netAmount {
                amount
              },
              app {
                name
              },
              shop {
                myshopifyDomain
              }
            },
            # skipped LegacyTransaction, not sure what it is
            ... on ReferralAdjustment {
              amount {
                amount
              },
              shop {
                myshopifyDomain
              }
            },
            ... on ReferralTransaction {
              amount {
                amount
              },
              shopNonNullable: shop {
                myshopifyDomain
              }
            },
            ... on ServiceSale {
              netAmount {
                amount
              },
              shop {
                myshopifyDomain
              }
            },
            ... on ServiceSaleAdjustment {
              netAmount {
                amount
              },
              shop {
                myshopifyDomain
              }
            },
            # skipped TaxTransaction
            ... on ThemeSale {
              netAmount {
                amount
              },
              theme {
                name # may not match CSV import behaviour
              },
              shop {
                myshopifyDomain
              }
            },
            ... on ThemeSaleAdjustment {
              netAmount {
                amount
              },
              theme {
                name # may not match CSV import behaviour
              },
              shop {
                myshopifyDomain
              }
            },
          }
        },
        pageInfo {
            hasNextPage
        }
      }
    }
  GRAPHQL

  belongs_to :user
  validates :user_id, presence: true

  class << self
    def import_csv(current_user, last_calculated_metric_date, filename)
      temp = Tempfile.new("import")
      s3 = Aws::S3::Client.new
      file = s3.get_object(
        {bucket: "partner-metrics",
         key: filename,}, target: temp.path
      )
      if filename.include?(".zip")
        Zip.on_exists_proc = true
        Zip.continue_on_exists_proc = true
        Zip::File.open(temp.path) do |zip_file|
          # Handle entries one by one
          zip_file.each do |entry|
            file = Tempfile.new("extracted")
            # Extract to file/directory/symlink
            Rails.logger.info("Extracting #{entry.name}")
            entry.extract(file)
          end
        end
      else
        file = temp
      end
      current_user.payment_histories.where("payment_date > ?", last_calculated_metric_date).delete_all
      key_mappings = {
        shop: :shop,
        shop_country: :shop_country,
        charge_creation_time: :payment_date,
        charge_type: :charge_type,
        partner_share: :revenue,
        app_title: :app_title,
      }
      options = {
        key_mapping: key_mappings,
        remove_unmapped_keys: true,
        chunk_size: 1000,
        force_utf8: true,
      }
      chunk_count = 0
      SmarterCSV.process(file, options) do |csv_chunk|
        chunk_payments = []
        chunk_count += 1
        csv_chunk.each do |csv|
          if csv[:payment_date].present? && !csv[:revenue].to_f != 0.0 && (Date.parse(csv[:payment_date]) > last_calculated_metric_date)
            csv[:app_title] = "Unknown" if csv[:app_title].blank?
            csv[:charge_type] =
              case csv[:charge_type]

              when "RecurringApplicationFee",
                    "Recurring application fee",
                    "Usage application fee",
                    "App sale – recurring",
                    "App sale – usage",
                    "App sale – subscription",
                    "App sale – 30-day subscription",
                    "App sale – yearly subscription"
                "recurring_revenue"
              when "OneTimeApplicationFee",
                    "ThemePurchaseFee",
                    "One time application fee",
                    "Theme purchase fee",
                    "App sale – one-time"
                "onetime_revenue"
              when "AffiliateFee",
                    "Affiliate fee",
                    "Development store referral commission",
                    "Affiliate referral commission"
                "affiliate_revenue"
              when "Manual",
                    "ApplicationDowngradeAdjustment",
                    "ApplicationCredit",
                    "AffiliateFeeRefundAdjustment",
                    "Application credit",
                    "Application downgrade adjustment",
                    "Application fee refund adjustment",
                    "App credit",
                    "App refund",
                    "App credit refund",
                    "Payout correction",
                    "App downgrade"
                "refund"
              else
                csv[:charge_type]
              end
            chunk_payments << current_user.payment_histories.new(csv)
          end
        end
        PaymentHistory.import chunk_payments
        current_user.update(import: "Importing (#{chunk_count},000 rows processed)", import_status: 100)
        Rails.logger.info("Chunk: #{chunk_count}")
        if chunk_count % 10 == 0
          GC.start
          Rails.logger.info("GC Started on Payments")
        end
      end
      temp.close
      file.close
      Rails.logger.info("Total chunks: #{chunk_count}")
    rescue => e
      current_user.update(import: "Failed", import_status: 100)
      Rails.logger.info(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
      raise e
    end

    def import_partner_api(current_user, last_calculated_metric_date)
      current_user.payment_histories.where("payment_date > ?", last_calculated_metric_date).delete_all

      cursor = ""
      has_next_page = true
      created_at_min = last_calculated_metric_date.strftime("%Y-%m-%dT%H:%M:%S.%L%z") # ISO-8601
      throttle_start_time = Time.zone.now

      while has_next_page == true
        throttle_start_time = throttle(throttle_start_time)
        transactions = []
        records = []
        results = ShopifyPartnerAPI.client.query(
          TransactionsQuery,
          variables: {createdAtMin: created_at_min, cursor: cursor},
          context: {access_token: current_user.partner_api_access_token, organization_id: current_user.partner_api_organization_id}
        )
        raise StandardError.new(results.errors.messages.map { |k, v| "#{k}=#{v}" }.join("&")) if results.errors.any?
        return if results.data.nil?
        transactions = results.data.transactions.edges
        Rails.logger.info("Number of Transactions: " + transactions.size.to_s)
        has_next_page = results.data.transactions.page_info.has_next_page
        cursor = results.data.transactions.edges.last.cursor
        transactions.each do |transaction|
          node = transaction.node

          created_at = Date.parse(node.created_at)

          next if created_at <= last_calculated_metric_date

          record = PaymentHistory.new(user_id: current_user.id)

          record.payment_date = created_at
          record.charge_type = lookup_charge_type(node.__typename)

          record.revenue = case node.__typename
            when "ReferralAdjustment",
              "ReferralTransaction"
              node.amount.amount
            else
              node.net_amount.amount
          end

          record.app_title = case node.__typename
            when "ReferralAdjustment",
              "ReferralTransaction",
              "ServiceSale",
              "ServiceSaleAdjustment"
              nil
            when "ThemeSaleAdjustment",
              "ThemeSale"
              node.theme.name
            else
              node.app.name
          end

          record.shop = case node.__typename
            when "ReferralTransaction"
              node.shop_non_nullable.myshopify_domain
            else
              node.shop.myshopify_domain
          end
          records << record
        end
        PaymentHistory.import(records)
      end
    rescue => e
      current_user.update(import: "Failed", import_status: 100)
      Rails.logger.info(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
      Rails.logger.info(transactions.to_json) if transactions.present?
      raise e
    end

    def calculate_metrics(current_user)
      current_user.update(import: "Calculating metrics (Warming up)", import_status: 0)
      # We want metrics broken up into their respective charge types (Recurring, OneTime, Affiliate), as well as by which application. We also want calculations for every day, for chart purposes.
      charge_types = ["recurring_revenue", "onetime_revenue", "affiliate_revenue", "refund"]
      latest_calculated_metric = current_user.metrics.order("metric_date").last
      calculate_from = if latest_calculated_metric.present?
        latest_calculated_metric.metric_date + 1.day
      elsif current_user.payment_histories.any?
        current_user.payment_histories.order("payment_date").first.payment_date
      else
        6.months.ago.to_date
      end
      Rails.logger.info(calculate_from)
      last_imported_payment = current_user.payment_histories.maximum(:payment_date)
      Rails.logger.info(last_imported_payment)
      if last_imported_payment.present?
        calculate_to = last_imported_payment - 1.day # Process only full days (export day may contain partial data)
        # Loop through each date in the range
        total_days = (calculate_to - calculate_from).to_i
        total_days = 1 if total_days == 0
        Rails.logger.info(total_days.to_s)
        days_processed = 0
        calculate_from.upto(calculate_to) do |date|
          Rails.logger.info(date.inspect)
          metrics_for_date = []
          # Then loop through each of the charge types
          Array(charge_types).each do |charge_type|
            # Then loop through each of the app titles for this charge type to calculate those specific metrics for the day
            app_titles = current_user.payment_histories.where(charge_type: charge_type).uniq.pluck(:app_title)
            Array(app_titles).each do |app_title|
              payments = current_user.payment_histories.where(payment_date: date, charge_type: charge_type, app_title: app_title)
              # Here's where the magic happens
              revenue = payments.sum(:revenue)
              number_of_charges = payments.count
              if number_of_charges != 0
                number_of_shops = payments.uniq.pluck(:shop).size
                average_revenue_per_shop = revenue / number_of_shops
                average_revenue_per_shop = 0.0 if average_revenue_per_shop.nan?
                average_revenue_per_charge = revenue / number_of_charges
                average_revenue_per_charge = 0.0 if average_revenue_per_charge.nan?
                revenue_churn = 0.0
                shop_churn = 0.0
                lifetime_value = 0.0
                repeat_customers = 0
                repeat_vs_new_customers = 0.0
                # Calculate Repeat Customers
                if charge_type == "onetime_revenue"
                  payments.uniq.pluck(:shop).each do |shop|
                    previous_purchase_count = current_user.payment_histories.where(shop: shop, payment_date: calculate_from..date, charge_type: charge_type, app_title: app_title).count
                    repeat_customers += 1 if previous_purchase_count > 1
                  end
                  repeat_vs_new_customers = repeat_customers.to_f / number_of_shops * 100
                end

                # Calculate Churn - Note: A shop should be charged every 30 days, however
                # in reality this is not always the case, due to Frozen charges. This means churn will
                # never be 100% accurate with only payment data to work.
                if charge_type == "recurring_revenue" || charge_type == "affiliate_revenue"
                  previous_shops = current_user.payment_histories.where(payment_date: date - 59.days..date - 30.days, charge_type: charge_type, app_title: app_title).group_by(&:shop)
                  if previous_shops.size != 0
                    current_shops = current_user.payment_histories.where(payment_date: date - 29.days..date, charge_type: charge_type, app_title: app_title).group_by(&:shop)
                    churned_shops = previous_shops.reject { |h| current_shops.include? h }
                    shop_churn = churned_shops.size / previous_shops.size.to_f
                    shop_churn = 0.0 if shop_churn.nan?
                    churned_sum = 0.0
                    churned_shops.each do |shop|
                      shop[1].each do |payment|
                        churned_sum += payment.revenue
                      end
                    end
                    previous_sum = 0.0
                    previous_shops.each do |shop|
                      shop[1].each do |payment|
                        previous_sum += payment.revenue
                      end
                    end
                    revenue_churn = churned_sum / previous_sum
                    revenue_churn = 0.0 if revenue_churn.nan?
                    revenue_churn *= 100
                    lifetime_value = ((previous_sum / previous_shops.size) / shop_churn) if shop_churn != 0.0
                    shop_churn *= 100
                  end
                end

                metrics_for_date << current_user.metrics.new(
                  metric_date: date,
                  charge_type: charge_type,
                  app_title: app_title,
                  revenue: revenue,
                  number_of_charges: number_of_charges,
                  number_of_shops: number_of_shops,
                  average_revenue_per_shop: average_revenue_per_shop,
                  average_revenue_per_charge: average_revenue_per_charge,
                  revenue_churn: revenue_churn,
                  shop_churn: shop_churn,
                  lifetime_value: lifetime_value,
                  repeat_customers: repeat_customers,
                  repeat_vs_new_customers: repeat_vs_new_customers
                )
              end
            end
          end
          Metric.import metrics_for_date
          days_processed += 1
          import_status = ((days_processed.to_f / total_days.to_f) * 100.0).to_i
          current_user.update(import: "Calculating metrics (#{date} processed)", import_status: import_status)
          if days_processed % 30 == 0
            GC.start
            Rails.logger.info("GC Started on Metrics")
          end
        end
      end
      current_user.update(import: "Complete", import_status: 100)
    rescue => e
      current_user.update(import: "Failed", import_status: 100)
      Rails.logger.info(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
      raise e
    end

    private

    def throttle(start_time)
      stop_time = Time.zone.now
      processing_duration = stop_time - start_time
      wait_time = (0.3 - processing_duration).round(1)
      Rails.logger.info("THROTTLING: #{wait_time}")
      sleep wait_time if wait_time > 0.0
      Time.zone.now
    end

    def lookup_charge_type(api_type)
      case api_type
      when "AppSubscriptionSale",
        "AppUsageSale"
        "recurring_revenue"
      when "AppOneTimeSale",
        "ServiceSale",
        "ThemeSale"
        "onetime_revenue"
      when "ReferralTransaction"
        "affiliate_revenue"
      when "AppSaleAdjustment",
      "AppSaleCredit",
        "ReferralAdjustment",
        "ServiceSaleAdjustment",
        "ThemeSaleAdjustment"
        "refund"
      else
        api_type
      end
    end
  end
end
