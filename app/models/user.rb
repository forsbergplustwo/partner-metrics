class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  has_many :payment_histories, dependent: :delete_all
  has_many :metrics, dependent: :delete_all

  def app_titles(charge_type)
    if charge_type.present?
      metrics.where(charge_type: charge_type)
    else
      metrics
    end.pluck(:app_title).uniq
  end

  # These should probably be in Metric.rb
  def newest_metric_date
    metrics.order("metric_date").last.metric_date
  end

  def oldest_metric_date
    metrics.order("metric_date").first.metric_date
  end

  def has_partner_api_credentials?
    partner_api_access_token.present? && partner_api_organization_id.present?
  end

  def yearly_revenue_per_product(date:, charge_type: nil)
    if charge_type
      metrics.where(metric_date: 12.months.ago..date, charge_type: charge_type)
    else
      metrics.where(metric_date: 12.months.ago..date)
    end.group(:app_title).sum(:revenue)
  end

  def yearly_revenue_per_country(date:, charge_type: nil)
    if charge_type
      payment_histories.where(payment_date: 12.months.ago..date, charge_type: charge_type)
    else
      payment_histories.where(payment_date: 12.months.ago..date)
    end.where("revenue > ?", 0).group(:shop_country).order("sum_revenue DESC").sum(:revenue)
  end

  def yearly_revenue_per_charge_type(date:, charge_type: nil)
    if charge_type
      metrics.where(metric_date: 12.months.ago..date, charge_type: charge_type)
    else
      metrics.where(metric_date: 12.months.ago..date)
    end.group(:charge_type).sum(:revenue)
  end

  def total_revenue_per_charge_type(from_date:, date:, charge_type: nil)
    if charge_type
      metrics.where(metric_date: from_date..date, charge_type: charge_type)
    else
      metrics.where(metric_date: from_date..date)
    end.group(:charge_type).sum(:revenue)
  end

  def total_revenue_per_app(from_date:, date:, charge_type: nil)
    if charge_type
      metrics.where(metric_date: from_date..date, charge_type: charge_type)
    else
      metrics.where(metric_date: from_date..date)
    end.group(:app_title).sum(:revenue)
  end
end
