class Metrics::RecurringController < MetricsController
  def index
    render "metrics/index"
  end

  private

  def set_tiles
    @tiles = Metric::RECURRING_TILES
    @selected_chart = selected_chart(tiles: @tiles, selected: params["chart"])
  end

  def charge_type
    "recurring_revenue"
  end
end
