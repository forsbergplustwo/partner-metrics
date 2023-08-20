class Metrics::OnetimeController < MetricsController

  def index
  end

  private

  def set_tiles
    @tiles = Metric::ONETIME_TILES
    @chart_tile = chart_tile(tiles: @tiles, selected: params["chart"])
  end

  def charge_type
    "onetime_revenue"
  end
end
