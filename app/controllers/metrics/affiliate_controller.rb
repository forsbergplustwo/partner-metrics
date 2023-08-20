class Metrics::AffiliateController < MetricsController
  def index
  end

  private

  def set_tiles
    @tiles = Metric::AFFILIATE_TILES
    @chart_tile = chart_tile(tiles: @tiles, selected: params["chart"])
  end

  def charge_type
    "affiliate_revenue"
  end
end
