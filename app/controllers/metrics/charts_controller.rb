class Metrics::ChartsController < MetricsController
  def show
    @metrics = Metric.get_chart_data(current_user, params["date"], params["period"].to_i, params["chart_type"], params["app_title"])
    render json: @metrics
  end
end
