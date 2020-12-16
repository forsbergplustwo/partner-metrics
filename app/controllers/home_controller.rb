class HomeController < ApplicationController
  before_action :authenticate_user!, except: :index
  before_action :set_params, except: [:index, :chart_data, :import, :prospectus]
  before_action :set_s3_direct_post, except: [:chart_data, :import]

  def index
    if current_user.present?
      redirect_to overview_path
    end
  end

  def overview
    @metrics = current_user.metrics.where(metric_date: @date_last..@date)
    @previous_metrics = current_user.metrics.where(metric_date: @previous_date_last..@previous_date)
    @tiles = Metric::OVERVIEW_TILES
    @chart_tile = if params["chart"].present?
      @tiles.find { |t| t["type"] == params["chart"] }
    else
      @tiles.first
    end
  end

  def recurring
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

  def onetime
    @app_titles = ["All"] + current_user.metrics.where(charge_type: "onetime_revenue").uniq.pluck(:app_title)
    if params["app_title"].blank? || params["app_title"] == "All"
      m = current_user.metrics.where(charge_type: "onetime_revenue")
    else
      @app_title = params["app_title"]
      m = current_user.metrics.where(app_title: params["app_title"], charge_type: "onetime_revenue")
    end
    @metrics = m.where(metric_date: @date_last..@date)
    @previous_metrics = m.where(metric_date: @previous_date_last..@previous_date)
    @tiles = Metric::ONETIME_TILES
    @chart_tile = if params["chart"].present?
      @tiles.find { |t| t["type"] == params["chart"] }
    else
      @tiles.first
    end
  end

  def affiliate
    if params["app_title"].blank? || params["app_title"] == "All"
      m = current_user.metrics.where(charge_type: "affiliate_revenue")
    else
      @app_title = params["app_title"]
      m = current_user.metrics.where(app_title: params["app_title"], charge_type: "affiliate_revenue")
    end
    @metrics = m.where(metric_date: @date_last..@date)
    @previous_metrics = m.where(metric_date: @previous_date_last..@previous_date)
    @tiles = Metric::AFFILIATE_TILES
    @chart_tile = if params["chart"].present?
      @tiles.find { |t| t["type"] == params["chart"] }
    else
      @tiles.first
    end
  end

  def prospectus
    @app_titles = ["All"] + current_user.payment_histories.pluck(:app_title).uniq
    if params["app_title"].blank? || params["app_title"] == "All"
      payments = current_user.payment_histories
      metrics = current_user.metrics
    else
      @app_title = params["app_title"]
      payments = current_user.payment_histories.where(app_title: params["app_title"])
      metrics = current_user.metrics.where(app_title: params["app_title"])
    end
    @latest_metric_date = begin
                            metrics.last.payment_date
                          rescue
                            Time.zone.now
                          end
    @payments_count = payments.group_by_month(:payment_date, reverse: true, last: 48).count
    @payments_revenue = payments.group_by_month(:payment_date, reverse: true, last: 48).sum(:revenue)
    @metrics_revenue_churn = metrics.group_by_month(:metric_date, reverse: true, last: 48).average(:revenue_churn)
    @metrics_user_churn = metrics.group_by_month(:metric_date, reverse: true, last: 48).average(:shop_churn)
    @payments_users = payments.group(:shop).count(:payment_date)
    @payments_user_revenue = payments.group(:shop).sum(:revenue)
    @payments_user_last_payment = payments.group(:shop).maximum(:payment_date)
  end

  def chart_data
    @metrics = Metric.get_chart_data(current_user, params["date"], params["period"].to_i, params["chart_type"], params["app_title"])
    render json: @metrics
  end

  def import
    filename = params[:file]
    current_user.update(import: "Importing", import_status: 100)
    Resque.enqueue(ImportWorker, current_user.id, filename)
    head :ok
  end

  def import_status
    render nothing: true unless request.xhr?
    label = current_user.import
    if label.include?("Importing") || label.include?("Calculating metrics")
      amount_done = current_user.import_status
      reload = false
    elsif label.include?("Complete")
      amount_done = current_user.import_status
      reload = true
      flash[:notice] = "Metrics successfully updated!"
    elsif label.include?("Failed")
      amount_done = current_user.import_status
      reload = true
      flash[:error] = "Something went wrong during import! Make sure the file you are uploading was exported using <a href='export-button.png' target='_blank'>this exact button</a> within your Shopify Partner Dashboard. Your Partner Dashboard in Shopify must be in English, otherwise Shopify changes the column names in the CSV files which causes problems.<br>If troubles continue, please feel free to get in contact on: <a href='mailto:bjorn@forsbergplustwo.com' target='_blank'>bjorn@forsbergplustwo.com</a>"
    end
    flash.keep
    render json: {
      reload: reload,
      label: label,
      amount_done: amount_done,
    }
  end

  def reset_metrics
    current_user.metrics.delete_all
    current_user.payment_histories.delete_all
    flash[:notice] = "Metrics successfully reset!"
    redirect_to root_path
  end

  private

  def set_params
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

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: "201")
  end
end
