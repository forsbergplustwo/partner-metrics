class Metric::Calculator
  def initialize(user:, date:, charge_type:, app_title:)
    @user = user
    @date = date
    @charge_type = charge_type
    @app_title = app_title
    @payments = user.payments.where(payment_date: date, charge_type: charge_type, app_title: app_title)
  end

  attr_reader :user, :date, :charge_type, :app_title, :payments

  def has_metrics?
    payments.any?
  end

  def revenue
    @revenue ||= payments.sum(:revenue)
  end

  def number_of_charges
    @number_of_charges ||= payments.count
  end

  def number_of_shops
    @number_of_shops ||= unique_shops.size
  end

  def average_revenue_per_shop
    return 0.0 if number_of_shops.zero?
    revenue / number_of_shops
  end

  def average_revenue_per_charge
    return 0.0 if number_of_charges.zero?
    revenue / number_of_charges
  end

  def repeat_customers
    @repeat_customers ||= begin
      return 0.0 if not_repeatable_charge_type?

      bulk_data = user.payments.where(
        shop: unique_shops,
        payment_date: ..date,
        charge_type: "onetime_revenue",
        app_title: app_title
      ).group(:shop).count

      unique_shops.count { |shop| bulk_data[shop] && bulk_data[shop] > 1 }
    end
  end

  def repeat_vs_new_customers
    return 0.0 if number_of_shops.zero? || not_repeatable_charge_type?
    repeat_customers.to_f / number_of_shops * 100
  end

  def revenue_churn
    return 0.0 if previous_shops.empty? || not_churnable_charge_type?
    revenue_churn = churned_sum / previous_sum
    revenue_churn.nan? ? 0.0 : revenue_churn * 100
  end

  def shop_churn
    return 0.0 if previous_shops.empty? || not_churnable_charge_type?
    shop_churn = churned_shops.size / previous_shops.size.to_f
    shop_churn.nan? ? 0.0 : shop_churn * 100
  end

  def lifetime_value
    return 0.0 if previous_shops.empty? || shop_churn.zero? || not_churnable_charge_type?
    previous_sum / previous_shops.size / (shop_churn / 100)
  end

  private

  def unique_shops
    @unique_shops ||= payments.pluck(:shop).uniq
  end

  def current_shops
    @current_shops ||= user.payments.where(payment_date: date - 29.days..date, charge_type: charge_type, app_title: app_title).group_by(&:shop)
  end

  def previous_shops
    @previous_shops ||= user.payments.where(payment_date: date - 59.days..date - 30.days, charge_type: charge_type, app_title: app_title).group_by(&:shop)
  end

  def churned_shops
    @churned_shops ||= previous_shops.reject { |h| current_shops.include? h }
  end

  def churned_sum
    churned_shops.sum { |_, payments| payments.sum(&:revenue) }
  end

  def previous_sum
    previous_shops.sum { |_, payments| payments.sum(&:revenue) }
  end

  def not_repeatable_charge_type?
    charge_type != "onetime_revenue"
  end

  def not_churnable_charge_type?
    charge_type != "recurring_revenue" && charge_type != "affiliate_revenue"
  end
end
