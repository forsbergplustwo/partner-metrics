class Metric::TileForFilter
  # {"handle" => "affiliate_revenue", "title" => "Revenue", "calculation" => "sum", "metric_type" => "affiliate_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"}

  def initialize(filter:, tile_config:)
    @filter = filter

    @handle = tile_config[:handle]
    @title = tile_config[:title]
    @calculation = tile_config[:calculation]
    @metric_type = tile_config[:metric_type]
    @column = tile_config[:column]
    @display = tile_config[:display]
    @direction_good = tile_config[:direction_good]
  end
  attr_reader :handle, :title, :display, :direction_good

  def current_value
    metrics = @filter.current_period_metrics
    metrics = metrics.where(charge_type: @metric_type) unless @metric_type.blank?
    metrics.calculate_value(@calculation, @column) || 0
  end

  def previous_value
    metrics = @filter.previous_period_metrics
    metrics = metrics.where(charge_type: @metric_type) unless @metric_type.blank?
    metrics.calculate_value(@calculation, @column) || 0
  end

  def change
    return 0 if current_value.blank? || previous_value.blank?
    (current_value.to_f / previous_value * 100) - 100
  end

  def direction_good?
    @direction_good == "up"
  end

  def chart_data
    metrics = @filter.user_metrics_by_app
    metrics = metrics.where(charge_type: @metric_type) unless @metric_type.blank?
    metrics.chart_data(@filter.date, @filter.period, @calculation, @column)
  end
end
