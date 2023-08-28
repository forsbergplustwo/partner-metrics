# TODO: Refactor this class to be more readable and maintainable
# 1. Move the logic for calculating the metrics into a metric::calculator PORO model
# 2. Split the CSV import into separate class
# 3. Split the Partner API import into separate class

class PaymentHistory < ApplicationRecord
  YEARS_TO_IMPORT = 4.years.freeze

  UNKNOWN_APP_TITLE = "Unknown".freeze

  belongs_to :user
  validates :user_id, presence: true

  class << self
    def default_start_date
      YEARS_TO_IMPORT.ago.to_date
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
        PaymentHistory.default_start_date
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
          metrics_for_date = nil
          if days_processed % 30 == 0
            GC.start
            Rails.logger.info("GC Started on Metrics")
          end
        end
      end
      current_user.update(import: "Complete", import_status: 100, partner_api_errors: "")
    rescue => e
      current_user.update(import: "Failed", import_status: 100, partner_api_errors: "Error: #{e.message}")
      raise e
    end
  end
end
