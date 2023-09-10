class Metric::TilesPresenter
  extend Metric::TilesConfig

  def initialize(filter:)
    @filter = filter
  end

  def tiles
    @tiles ||= build_tiles
  end

  def selected_tile
    chart = @filter.chart.presence || default_chart
    tiles.find { |t| t.handle.to_s == chart }
  end

  private

  def build_tiles
    tiles_for_charge_type.collect do |tile|
      Metric::TilePresenter.new(filter: @filter, tile_config: tile)
    end
  end

  def tiles_for_charge_type
    case @filter.charge_type&.to_sym
    when :recurring_revenue
      Metric::TilesConfig::RECURRING_TILES
    when :onetime_revenue
      Metric::TilesConfig::ONETIME_TILES
    when :affiliate_revenue
      Metric::TilesConfig::AFFILIATE_TILES
    else
      Metric::TilesConfig::OVERVIEW_TILES
    end
  end

  def default_chart
    tiles.first.handle.to_s
  end
end
