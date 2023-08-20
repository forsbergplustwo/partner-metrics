class MetricsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_data
  include Importable

  def index
  end

  private

  def charge_type
    nil
  end

  def set_data
    set_dates
    set_app_titles
    set_metrics
    set_tiles
  end

  def set_dates
    @first_metric_date = current_user.oldest_metric_date
    @latest_metric_date = current_user.newest_metric_date
  end

  def set_app_titles
    @app_titles = ["All"] + current_user.app_titles(charge_type)
  end

  def set_metrics
    metrics_filterer = Metrics::Filterer.new(
      user: current_user,
      date: date_param,
      period: period_param,
      app_title: app_title_param,
      charge_type: charge_type
    )

    @metrics = metrics_filterer.metrics
    @previous_metrics = metrics_filterer.previous_metrics
  end

  def set_tiles
    @tiles = Metric::OVERVIEW_TILES
    @chart_tile = chart_tile(tiles: @tiles, selected: params["chart"])
  end

  def app_title_param
    @app_title = if params[:app_title].present? && params[:app_title] != "All"
      params[:app_title].to_s
    else
      nil
    end
  end

  def period_param
    @period = if params[:period].present?
     params[:period].to_i
    else
      30
    end
  end

  def date_param
    @date = if params[:date].present?
      Date.parse(params[:date].to_s)
    else
      @latest_metric_date
    end
  end

  def chart_tile(tiles:, selected: nil)
    if selected.present?
      tiles.find { |t| t["type"] == selected }
    else
      tiles.first
    end
  end

end
