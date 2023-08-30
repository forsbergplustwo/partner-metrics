# TODO: Refactor this controller to not use so many instance variables
class MetricsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_data

  def index
  end

  private

  def charge_type
    nil
  end

  def set_data
    set_app_titles
    set_metrics
    set_tiles
  end

  def set_app_titles
    @app_titles = current_user.app_titles(charge_type)
  end

  def set_metrics
    metrics_filterer = Metric::Filterer.new(
      user: current_user,
      date: date_param,
      period: period_param,
      selected_app: selected_app_param,
      charge_type: charge_type
    )

    @metrics = metrics_filterer.metrics
    @previous_metrics = metrics_filterer.previous_metrics
  end

  def set_tiles
    @tiles = Metric::OVERVIEW_TILES
    @selected_chart = selected_chart(tiles: @tiles, selected: params["chart"])
  end

  def selected_app_param
    @selected_app = params[:selected_app].to_s
  end

  def period_param
    @period = if params[:period].present?
      params[:period].to_i
    else
      30
    end
  end

  def date_param
    @selected_or_latest_date = if params[:date].present?
      Date.parse(params[:date].to_s)
    else
      current_user.newest_metric_date || Time.zone.today
    end
  end

  def selected_chart(tiles:, selected: nil)
    if selected.present?
      tiles.find { |t| t["type"] == selected }
    else
      tiles.first
    end
  end
end
