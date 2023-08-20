class Metrics::Filterer
  def initialize(user:, date:, period:, app_title: , charge_type:)
    @user = user
    @date = Date.parse(date.to_s)
    @period = period.to_i
    @app_title = app_title == "All" ? nil : app_title
    @charge_type = charge_type
  end

  def metrics
    metrics_for_date(@date)
  end

  def previous_metrics
    previous_period = @date - @period.days
    metrics_for_date(previous_date)
  end

  def previous_date
    @date - @period.days
  end

  private

  def metrics_for_date(date)
    metrics = @user.metrics.where(metric_date: date)
    metrics.where(app_title: @app_title) if @app_title.present?
    metrics.where(charge_type: @charge_type) if @charge_type.present?
    metrics
  end

end
