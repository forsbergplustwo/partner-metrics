class Metrics::RecurringController < MetricsController
  def index
  end

  private

  def set_tiles
    @tiles = Metric::RECURRING_TILES
    @chart_tile = chart_tile(tiles: @tiles, selected: params["chart"])
  end

  def charge_type
    "recurring_revenue"
  end
end
