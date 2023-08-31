# TODO: Refactor this controller to not use so many instance variables
class MetricsController < ApplicationController
  before_action :authenticate_user!
  before_action :default_query!, if: -> { params[:q].blank? }
  before_action :set_metrics

  def index
  end

  private

  def default_query!
    chart = current_tiles.first
    date = current_user.newest_metric_date_or_today

    q = Metric::QueryParams.new(
      date: date,
      chart: chart["type"],
      period: 30,
      app: nil
    ).to_param

    redirect_to url_for(action: action_name, q: q)
  end

  def set_metrics
    date = current_query[:date]
    period = current_query[:period]
    previous_date = date - period.days + 1

    @metrics = metrics_for_range(date, period)
    @previous_metrics = metrics_for_range(previous_date, period)
  end

  def metrics_for_range(date, period)
    current_user.metrics.for_range_and_query(
      date: date,
      period: period,
      app_title: current_query[:app],
      charge_type: current_charge_type
    )
  end

  def current_charge_type
    @current_charge_type ||= Metric.charge_type_for(controller_name)
  end
  helper_method :current_charge_type

  def current_tiles
    @current_tiles ||= Metric.tiles_for(controller_name)
  end
  helper_method :current_tiles

  def current_query
    @current_query ||= Metric::QueryParams.new(query_params).to_param
  end
  helper_method :current_query

  def query_params
    params[:q]&.permit(
      :app,
      :chart,
      :date,
      :period
    )
  end
end
