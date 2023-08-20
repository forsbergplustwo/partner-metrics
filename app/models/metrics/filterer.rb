class Metrics::Filterer
  def initialize(user:, date:, period:, app_title: , charge_type:)
    @user = user
    @date = date.present? ? Date.parse(date.to_s) : @user.latest_metric_date
    @period = period
    @app_title = (app_title == "All" ? nil : app_title)
    @charge_type = charge_type
  end

  def metrics
    previous_period = @date - @period.days + 1.day
    metrics_for_range(@date, previous_period)
  end

  def previous_metrics
    previous_period = previous_date - @period.days + 1
    metrics_for_range(previous_date, previous_period)
  end

  def previous_date
    @date - @period.days
  end

  private

  def metrics_for_range(start_date, end_date)
    metrics = @user.metrics.where(metric_date: end_date..start_date)
    metrics = metrics.where(app_title: @app_title) if @app_title.present?
    metrics = metrics.where(charge_type: @charge_type) if @charge_type.present?
    metrics
  end
end
