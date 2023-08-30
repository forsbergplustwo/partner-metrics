class Metrics::AffiliateController < MetricsController
  def index
    render "metrics/index"
  end

  private

  def set_tiles
    @tiles = Metric::AFFILIATE_TILES
    @selected_chart = selected_chart(tiles: @tiles, selected: params["chart"])
  end

  def charge_type
    "affiliate_revenue"
  end
end
