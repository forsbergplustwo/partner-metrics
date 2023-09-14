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
        app_titles = app_titles_for(date: date, charge_type: charge_type)
        next if app_titles.empty?

        app_titles.each do |app_title|
          calculator = Metric::Calculator.new(
            user: @user,
            date: date,
            charge_type: charge_type,
            app_title: app_title
          )
          metrics << new_metric_from(calculator: calculator) if calculator.has_metrics?
        end
      end
      Metric.import!(metrics, validate: false, no_returning: true) if metrics.present?
      @import.touch
    end
  end

  def app_titles_for(date:, charge_type:)
    @user.payments.where(payment_date: date, charge_type: charge_type).pluck(:app_title).uniq
  end

  def new_metric_from(calculator:)
    {
      user_id: @user.id,
      import_id: @import.id,
      metric_date: calculator.date,
      charge_type: calculator.charge_type,
      app_title: calculator.app_title,
      revenue: calculator.revenue,
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
