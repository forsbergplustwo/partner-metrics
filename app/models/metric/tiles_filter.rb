class Metric::TilesFilter
  def initialize(user:, params:)
    @user = user
    @date = params[:date]&.to_date || user.newest_metric_date_or_today
    @charge_type = params[:charge_type]&.to_s || nil
    @chart = params[:chart]&.to_s || nil
    @period = params[:period]&.to_i || 30
    @app = params[:app]&.to_s || nil
  end

  attr_reader :user, :date, :charge_type, :chart, :period, :app

  delegate :oldest_metric_date, :newest_metric_date_or_today, to: :user

  def app_titles
    @user.app_titles(@charge_type)
  end

  def tiles
    tiles_presenter.tiles
  end

  def selected_tile
    tiles_presenter.selected_tile
  end

  def has_metrics?
    current_period_metrics.any?
  end

  def user_metrics_by_app
    @user.metrics.by_optional_app_title(@app)
  end

  def current_period_metrics
    user_metrics_by_app.by_date_and_period(date: @date, period: @period)
  end

  def previous_period_metrics
    user_metrics_by_app.by_date_and_period(date: previous_date, period: @period)
  end

  def to_param
    {
      date: @date,
      charge_type: @charge_type,
      chart: @chart,
      period: @period,
      app: @app
    }
  end

  private

  def previous_date
    @date - @period.days + 1
  end

  def tiles_presenter
    @tiles_presenter ||= Metric::TilesPresenter.new(filter: self)
  end
end
