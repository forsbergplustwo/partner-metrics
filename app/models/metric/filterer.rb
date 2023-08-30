class Metric::Filterer
  def initialize(user:, date:, period:, selected_app:, charge_type:)
    @user = user
    @selected_or_latest_date = date
    @period = period
    @selected_app = selected_app
    @charge_type = charge_type
  end
  attr_reader :user, :selected_or_latest_date, :period, :selected_app, :charge_type

  def metrics
    previous_period = selected_or_latest_date - period.days + 1.day
    metrics_for_range(selected_or_latest_date, previous_period)
  end

  def previous_metrics
    previous_period = previous_date - period.days + 1
    metrics_for_range(previous_date, previous_period)
  end

  def previous_date
    selected_or_latest_date - period.days
  end

  private

  def metrics_for_range(start_date, end_date)
    metrics = user.metrics.where(metric_date: end_date..start_date)
    metrics = metrics.where(app_title: selected_app) if selected_app.present?
    metrics = metrics.where(charge_type: charge_type) if charge_type.present?
    metrics
  end
end
