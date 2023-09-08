class Import::MetricCalculator
  CHARGE_TYPES = ["recurring_revenue", "onetime_revenue", "affiliate_revenue", "refund"].freeze

  def initialize(import:)
    @import = import
    @user = @import.user
    @calculate_from, @calculate_to = calculation_dates
  end

  attr_accessor :import, :user, :calculate_from, :calculate_to

  def calculate_metrics!
    return if user.payments.none?
    calculate_new_metrics
  rescue => error
    import&.failed!
    raise error
  end

  private

  def calculate_new_metrics
    calculate_from.upto(calculate_to) do |date|
      metrics_for_date = []
      # Then loop through each of the charge types
      CHARGE_TYPES.each do |charge_type|
        # Then loop through each of the app titles for this charge type to calculate those specific metrics for the day
        app_titles = user.payments.where(charge_type: charge_type).pluck(:app_title).uniq
        app_titles.each do |app_title|
          payments = user.payments.where(payment_date: date, charge_type: charge_type, app_title: app_title)
          next if payments.empty?

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
                previous_purchase_count = user.payments.where(shop: shop, payment_date: calculate_from..date, charge_type: charge_type, app_title: app_title).count
                repeat_customers += 1 if previous_purchase_count > 1
              end
              repeat_vs_new_customers = repeat_customers.to_f / number_of_shops * 100
            end

            # Calculate Churn - Note: A shop should be charged every 30 days, however
            # in reality this is not always the case, due to Frozen charges. This means churn will
            # never be 100% accurate with only payment data to work.
            if charge_type == "recurring_revenue" || charge_type == "affiliate_revenue"
              previous_shops = user.payments.where(payment_date: date - 59.days..date - 30.days, charge_type: charge_type, app_title: app_title).group_by(&:shop)
              if previous_shops.size != 0
                current_shops = user.payments.where(payment_date: date - 29.days..date, charge_type: charge_type, app_title: app_title).group_by(&:shop)
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
                lifetime_value = ((previous_sum / previous_shops.size) / shop_churn) if shop_churn != 0
                shop_churn *= 100
              end
            end

            metrics_for_date << user.metrics.new(
              import: import,
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
      Metric.import!(metrics_for_date, validate: false, no_returning: true)
      import.touch
    end
  end

  def calculation_dates
    # TODO: Currently this needs to calculate on all payments, instead of just this Imports payments, due to partial date imports
    latest_calculated_metric = user.metrics.order("metric_date").last
    calculate_from = if latest_calculated_metric.present?
      latest_calculated_metric.metric_date + 1.day
    else
      user.payments.minimum("payment_date")
    end
    last_imported_payment = user.payments.maximum(:payment_date)
    calculate_to = last_imported_payment - 1.day
    [calculate_from, calculate_to]
  end
end
