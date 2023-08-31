class Metric::TileForFilter
  def initialize(filter:, tile_config:)
    @filter = filter

    @handle = tile_config[:handle]
    @charge_type = tile_config[:charge_type]
    @calculation = tile_config[:calculation]
    @column = tile_config[:column]
    @display = tile_config[:display]
    @positive_change_is_good = tile_config[:positive_change_is_good]
  end
  attr_reader :handle, :display, :calculation

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

  def positive_change_is_good?
    @positive_change_is_good == true
  end

  def chart_data
    metrics = @filter.user_metrics_by_app.by_optional_charge_type(@charge_type)
    metrics.chart_data(@filter.date, @filter.period, @calculation, @column)
  end
end
