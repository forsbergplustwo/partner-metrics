class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  has_many :payments, dependent: :delete_all
  has_many :metrics, dependent: :delete_all
  has_many :imports, dependent: :delete_all
  has_one :partner_api_credential, dependent: :destroy

  # TODO: These should probably be in metric model

  def app_titles(charge_type = nil)
    if charge_type.present?
      metrics.where(charge_type: charge_type)
    else
      metrics
    end.pluck(:app_title).uniq
  end

  def newest_metric_date
    metrics.maximum("metric_date")
  end

  def newest_metric_date_or_today
    newest_metric_date.presence || Time.zone.today.to_date
  end

  def oldest_metric_date
    metrics.minimum("metric_date")
  end

  def clear_old_payments!(after:)
    payments.where("payment_date > ?", after).delete_all
  end

  # TODO: DRY the following methods up

  def yearly_revenue_per_product(date:, charge_type: nil)
    if charge_type
      metrics.where(metric_date: 12.months.ago..date, charge_type: charge_type)
    else
      metrics.where(metric_date: 12.months.ago..date)
    end.group(:app_title).sum(:revenue)
  end

  def yearly_revenue_per_country(date:, charge_type: nil)
    if charge_type
      payments.where(payment_date: 12.months.ago..date, charge_type: charge_type)
    else
      payments.where(payment_date: 12.months.ago..date)
    end.where("revenue > ?", 0).group(:shop_country).order("sum_revenue DESC").sum(:revenue)
  end

  def yearly_revenue_per_charge_type(date:, charge_type: nil)
    if charge_type
      metrics.where(metric_date: 12.months.ago..date, charge_type: charge_type)
    else
      metrics.where(metric_date: 12.months.ago..date)
    end.group(:charge_type).sum(:revenue)
  end

  def total_revenue_per_charge_type(date:, charge_type: nil)
    from_date = oldest_metric_date || Time.zone.today
    if charge_type
      metrics.where(metric_date: from_date..date, charge_type: charge_type)
    else
      metrics.where(metric_date: from_date..date)
    end.group(:charge_type).sum(:revenue)
  end

  def total_revenue_per_app(date:, charge_type: nil)
    from_date = oldest_metric_date || Time.zone.today
    if charge_type
      metrics.where(metric_date: from_date..date, charge_type: charge_type)
    else
      metrics.where(metric_date: from_date..date)
    end.group(:app_title).sum(:revenue)
  end

  def total_revenue_per_plan(date:, charge_type:, period: nil, app_title: nil)
    per_plan_payments = payments.where(charge_type: charge_type)
    per_plan_payments = per_plan_payments.where(app_title: app_title) if app_title.present?
    per_plan_payments = if period.present?
      per_plan_payments.where(payment_date: (date - period.days)..date)
    else
      per_plan_payments.where(payment_date: ..date)
    end
    per_plan_payments.group(:revenue).order("revenue DESC").count
  end
end
