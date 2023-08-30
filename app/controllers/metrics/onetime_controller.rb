class Metrics::OnetimeController < MetricsController
  def index
    render "metrics/index"
  end

  private

  def set_tiles
    @tiles = Metric::ONETIME_TILES
    @selected_chart = selected_chart(tiles: @tiles, selected: params["chart"])
  end

  def charge_type
    "onetime_revenue"
  end
end
