class Import::MetricsProcessor
  def initialize(import:)
    @import = import
    @user = import.user
    @import_from = import.import_metrics_after_date
    @import_to = import.import_metrics_before_date
  end

  def calculate!
    return if @import_from.blank? || @import_to.blank?
    calculate_new_metrics
  rescue => error
    @import&.fail
    raise error
  end

  private

  def calculate_new_metrics
    @import_from.upto(@import_to) do |date|
      metrics = []
      Metric::CHARGE_TYPES.each do |charge_type|
        is_yearly_revenue_intervals_for(charge_type).each do |is_yearly_revenue|
          app_titles = app_titles_for(date: date, charge_type: charge_type, is_yearly_revenue: is_yearly_revenue)
          next if app_titles.empty?

          app_titles.each do |app_title|
            calculator = Metric::Calculator.new(
              user: @user,
              date: date,
              charge_type: charge_type,
              app_title: app_title,
              is_yearly_revenue: is_yearly_revenue
            )
            metrics << new_metric_from(calculator: calculator) if calculator.has_metrics?
          end
        end
      end
      Metric.import!(metrics, validate: false, no_returning: true) if metrics.present?
      @import.touch
    end
  end

  def is_yearly_revenue_intervals_for(charge_type)
    if Metric::CHARGE_TYPE_CAN_HAVE_YEARLY_INTERVAL[charge_type]
      [true, false]
    else
      [false]
    end
  end

  def app_titles_for(date:, charge_type:, is_yearly_revenue:)
    @user.payments.where(
      payment_date: date,
      charge_type: charge_type,
      is_yearly_revenue: is_yearly_revenue
    ).pluck(:app_title).uniq
  end

  def new_metric_from(calculator:)
    {
      user_id: @user.id,
      import_id: @import.id,
      metric_date: calculator.date,
      charge_type: calculator.charge_type,
      app_title: calculator.app_title,
      revenue: calculator.revenue,
      is_yearly_revenue: calculator.is_yearly_revenue,
      number_of_charges: calculator.number_of_charges,
      number_of_shops: calculator.number_of_shops,
      average_revenue_per_shop: calculator.average_revenue_per_shop,
      average_revenue_per_charge: calculator.average_revenue_per_charge,
      revenue_churn: calculator.revenue_churn,
      shop_churn: calculator.shop_churn,
      lifetime_value: calculator.lifetime_value,
      repeat_customers: calculator.repeat_customers,
      repeat_vs_new_customers: calculator.repeat_vs_new_customers
    }
  end
end
