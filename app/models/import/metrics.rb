class Import::Metrics
  def initialize(import:)
    @import = import
    @user = @import.user
    @import_from, @import_to = import_dates
  end

  attr_accessor :import, :user, :import_from, :import_to

  def calculate!
    return if import_from.blank? || import_to.blank?
    calculate_new_metrics
  rescue => error
    import&.failed!
    raise error
  end

  private

  def calculate_new_metrics
    import_from.upto(import_to) do |date|
      metrics = []
      Metric::CHARGE_TYPES.each do |charge_type|
        app_titles = app_titles_for(date: date, charge_type: charge_type)
        next if app_titles.empty?

        app_titles.each do |app_title|
          calculator = Metric::Calculator.new(
            user: user,
            date: date,
            charge_type: charge_type,
            app_title: app_title
          )
          metrics << new_metric_from(calculator: calculator) if calculator.has_metrics?
        end
      end
      Metric.import!(metrics.flatten.compact, validate: false, no_returning: true)
      import.touch
    end
  end

  def app_titles_for(date:, charge_type:)
    user.payments.where(payment_date: date, charge_type: charge_type).pluck(:app_title).uniq
  end

  def new_metric_from(calculator:)
    user.metrics.new(
      import: import,
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
    )
  end

  def import_dates
    # TODO: Returns dates for all payments, instead of just this Imports payments, because of partial dates.
    latest_calculated_metric = user.metrics.order("metric_date").last
    import_from = if latest_calculated_metric.present?
      latest_calculated_metric.metric_date + 1.day
    else
      user.payments.minimum("payment_date")
    end
    last_imported_payment = user.payments.maximum(:payment_date)
    import_to = last_imported_payment - 1.day
    [import_from, import_to]
  end
end
