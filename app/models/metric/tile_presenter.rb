class Metric::TilePresenter
  def initialize(filter:, tile_config:)
    @filter = filter

    @handle = tile_config[:handle]
    @charge_type = tile_config[:charge_type]
    @calculation = tile_config[:calculation]
    @column = tile_config[:column]
    @display = tile_config[:display]
    @positive_change_is_good = tile_config[:positive_change_is_good]
    @is_yearly_revenue = tile_config[:is_yearly_revenue]
    @width = tile_config[:width].presence || :third
  end
  attr_reader :handle, :display, :calculation, :positive_change_is_good, :is_yearly_revenue, :width

  def current_value
    metrics = @filter.current_period_metrics
      .by_optional_charge_type(@charge_type)
      .by_optional_is_yearly_revenue(@is_yearly_revenue)
      .calculate_value(@calculation, @column)
    metrics.blank? ? 0 : metrics
  end

  def previous_value
    metrics = @filter.previous_period_metrics
      .by_optional_charge_type(@charge_type)
      .by_optional_is_yearly_revenue(@is_yearly_revenue)
      .calculate_value(@calculation, @column)
    metrics.blank? ? 0 : metrics
  end

  def change
    return 0 if current_value.blank? || previous_value.blank?
    (current_value.to_f / previous_value * 100) - 100
  end

  def average_value
    return 0 if current_value.blank?
    current_value / @filter.period
  end

  def period_ago_value(period_ago)
    period_ago_date = @filter.date - (period_ago * @filter.period).days
    @filter.user_metrics_by_app
      .by_date_and_period(date: period_ago_date, period: @filter.period)
      .by_optional_charge_type(@charge_type)
      .by_optional_is_yearly_revenue(@is_yearly_revenue)
      .calculate_value(@calculation, @column)
  end

  def period_ago_change(period_ago)
    return 0 if current_value.blank? || period_ago_value(period_ago).blank?
    (current_value.to_f / period_ago_value(period_ago) * 100) - 100
  end

  def chart_data
    chart_data = basic_chart_data

    if @filter.show_forecasts? && @filter.period == 30
      forecast_data = forecast_chart_data(chart_data)
      return chart_data if forecast_data[:data].empty?
      chart_data << forecast_data
    end
    chart_data
  end

  private

  def basic_chart_data
    metrics_chart = metrics_chart_data
    [{name: @display, data: metrics_chart}]
  end

  def forecast_chart_data(chart_data)
    forecast_data = Metric::ForecastCharter.new(chart_data: metrics_chart_data).chart_data
    {name: "Forecast", data: forecast_data}
  end

  def metrics_chart_data
    @metrics_chart_data ||= @filter.user_metrics_by_app
      .by_optional_charge_type(@charge_type)
      .by_optional_is_yearly_revenue(@is_yearly_revenue)
      .chart_data(@filter.date, @filter.period, @calculation, @column)
      .to_h
  end
end
