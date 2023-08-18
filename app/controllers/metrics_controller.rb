class MetricsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_base_variables, except: [:import, :prospectus]
  include Importable

  def index
    if params["app_title"].blank? || params["app_title"] == "All"
      m = current_user.metrics
    else
      @app_title = params["app_title"]
      m = current_user.metrics.where(app_title: params["app_title"])
    end
    @metrics = m.where(metric_date: @date_last..@date)
    @previous_metrics = current_user.metrics.where(metric_date: @previous_date_last..@previous_date)
    @tiles = Metric::OVERVIEW_TILES
    @chart_tile = if params["chart"].present?
      @tiles.find { |t| t["type"] == params["chart"] }
    else
      @tiles.first
    end
  end

  private

  def set_base_variables
    @app_titles = ["All"] + current_user.metrics.where(charge_type: "recurring_revenue").uniq.pluck(:app_title)
    calculated_metrics = current_user.metrics.order("metric_date")
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
end
