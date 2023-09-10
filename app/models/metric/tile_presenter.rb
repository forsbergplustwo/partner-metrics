class Metric::TilePresenter
  def initialize(filter:, tile_config:)
    @filter = filter

    @handle = tile_config[:handle]
    @charge_type = tile_config[:charge_type]
    @calculation = tile_config[:calculation]
    @column = tile_config[:column]
    @display = tile_config[:display]
    @positive_change_is_good = tile_config[:positive_change_is_good]
  end
  attr_reader :handle, :display, :calculation, :positive_change_is_good

  def current_value
    metrics = @filter.current_period_metrics.by_optional_charge_type(@charge_type)
    metrics.calculate_value(@calculation, @column)
  end

  def previous_value
    metrics = @filter.previous_period_metrics.by_optional_charge_type(@charge_type)
    metrics.calculate_value(@calculation, @column)
  end

  def change
    return 0 if current_value.blank? || previous_value.blank?
    (current_value.to_f / previous_value * 100) - 100
  end

  def average_value
    current_value / @filter.period
  end

  def period_ago_value(period_ago)
    period_ago_date = @filter.date - (period_ago * @filter.period).days
    metrics = @filter.user_metrics_by_app.by_optional_charge_type(@charge_type)
    metrics.by_date_and_period(date: period_ago_date, period: @filter.period).calculate_value(@calculation, @column)
  end

  def period_ago_change(period_ago)
    return 0 if current_value.blank? || period_ago_value(period_ago).blank?
    (current_value.to_f / period_ago_value(period_ago) * 100) - 100
  end

  def chart_data
    metrics = @filter.user_metrics_by_app.by_optional_charge_type(@charge_type)
    metrics.chart_data(@filter.date, @filter.period, @calculation, @column)
  end
end
