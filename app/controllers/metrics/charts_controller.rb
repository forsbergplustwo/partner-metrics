class Metrics::ChartsController < MetricsController
  def show
    # TODO: Refector to scope in model
    @metrics = Metric.get_chart_data(current_user, params["date"], params["period"].to_i, params["chart_type"], params["selected_app"])
    render json: @metrics
  end
end
