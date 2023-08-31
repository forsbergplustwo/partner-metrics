class Metric::TilesForFilter
  extend TilesConfig

  def initialize(filter:)
    @filter = filter
  end

  def tiles
    @tiles ||= build_tiles
  end

  private

  def build_tiles
    tiles_for_charge_type.collect do |tile|
      Metric::TileForFilter.new(filter: @filter, tile_config: tile)
    end
  end

  def tiles_for_charge_type
    case @filter.charge_type&.to_sym
    when :recurring_revenue
      TilesConfig::RECURRING_TILES
    when :onetime_revenue
      TilesConfig::ONETIME_TILES
    when :affiliate_revenue
      TilesConfig::AFFILIATE_TILES
    else
      TilesConfig::OVERVIEW_TILES
    end
  end
end
