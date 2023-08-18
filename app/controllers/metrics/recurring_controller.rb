class Metrics::RecurringController < MetricsController

  def index
    @app_titles = ["All"] + current_user.metrics.where(charge_type: "recurring_revenue").uniq.pluck(:app_title)
    if params["app_title"].blank? || params["app_title"] == "All"
      m = current_user.metrics.where(charge_type: "recurring_revenue")
    else
      @app_title = params["app_title"]
      m = current_user.metrics.where(app_title: params["app_title"], charge_type: "recurring_revenue")
    end
    @metrics = m.where(metric_date: @date_last..@date)
    @previous_metrics = m.where(metric_date: @previous_date_last..@previous_date)
    @tiles = Metric::RECURRING_TILES
    @chart_tile = if params["chart"].present?
      @tiles.find { |t| t["type"] == params["chart"] }
    else
      @tiles.first
    end
  end
end
