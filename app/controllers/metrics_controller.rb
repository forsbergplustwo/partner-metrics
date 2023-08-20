class MetricsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_data
  include Importable

  def index
  end

  private

  def set_data
    set_dates
    set_app_titles
    set_metrics
    set_tiles
  end

  def app_title_param
    params[:app_title].presence || "All"
  end

  def period_param
    params[:period].presence || 30
  end

  def date_param
    params[:date].presence || @latest_metric_date
  end

  def chart_tile(tiles:, selected: nil)
    if selected.present?
      tiles.find { |t| t["type"] == selected }
    else
      tiles.first
    end
  end

  def charge_type
    nil
  end


  # TODO: Refactor this to PORO
  def set_dates
    calculated_metrics = current_user.metrics.order("metric_date")
    #Dates
    if calculated_metrics.present?
      @first_metric_date = calculated_metrics.first.metric_date
      @latest_metric_date = calculated_metrics.last.metric_date
      @range = params[:date]
      if @range.blank?
        @date = @latest_metric_date
        @period = 30
      else
        @date = Date.parse(@range)
        @period = params[:period].to_i
      end
      @date_last = @date - @period.days + 1.day
      @range = "#{@date_last.strftime("%b %d, %Y")} - #{@date.strftime("%b %d, %Y")}"
      @previous_date = @date - @period.days
      @previous_date_last = @previous_date - @period.days + 1.day
    else
      @first_metric_date = Time.zone.now.to_date
      @latest_metric_date = Time.zone.now.to_date
      @date = @latest_metric_date
      @period = 30
      @date_last = @date - @period.days + 1.day
      @range = "#{@date_last.strftime("%b %d, %Y")} - #{@date.strftime("%b %d, %Y")}"
    end
  end

  def set_app_titles
    @app_titles = ["All"] + current_user.metrics.where(charge_type: charge_type).uniq.pluck(:app_title)
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
    Rails.logger.info @metrics.inspect
    @previous_metrics = metrics_filterer.previous_metrics
  end

  def set_tiles
    @tiles = Metric::OVERVIEW_TILES
    @chart_tile = chart_tile(tiles: @tiles, selected: params["chart"])
  end

end
