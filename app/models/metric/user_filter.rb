class Metric::UserFilter
  def initialize(user:, params:)
    @user = user
    @date = params[:date]&.to_date || user.newest_metric_date_or_today
    @charge_type = params[:charge_type]&.to_s || nil
    @chart = params[:chart]&.to_s || default_chart
    @period = params[:period]&.to_i || 30
    @app = params[:app]&.to_s || nil
  end

  attr_reader :user, :date, :charge_type, :chart, :period, :app
  delegate :oldest_metric_date, :newest_metric_date_or_today, to: :user

  def tiles
    Metric::TilesForFilter.new(filter: self).tiles
  end

  def tile
    tiles.find { |t| t.handle.to_s == @chart }
  end

  def user_metrics_by_app
    @user.metrics.by_optional_app_title(@app)
  end

  def current_period_metrics
    user_metrics_by_app.by_date_and_period(date: @date, period: @period)
  end

  def previous_period_metrics
    previous_date = @date - @period.days + 1
    user_metrics_by_app.by_date_and_period(date: previous_date, period: @period)
  end

  def has_metrics?
    current_period_metrics.any?
  end

  def to_param
    {
      date: @date,
      charge_type: @charge_type,
      chart: @chart,
      app: @app,
      period: @period
    }
  end

  private

  def default_chart
    tiles.first.handle.to_s
  end
end
