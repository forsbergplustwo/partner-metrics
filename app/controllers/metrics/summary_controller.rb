class Metrics::SummaryController < MetricsController

  # TODO: Refactor -> This one is different from the others and needs re-thinking separately
  def index
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
    @payments_count = payments.group_by_month(:payment_date, reverse: true, last: 36).count
    @payments_revenue = payments.group_by_month(:payment_date, reverse: true, last: 36).sum(:revenue)
    @metrics_revenue_churn = metrics.group_by_month(:metric_date, reverse: true, last: 36).average(:revenue_churn)
    @metrics_user_churn = metrics.group_by_month(:metric_date, reverse: true, last: 36).average(:shop_churn)
    @payments_users = payments.group(:shop).count(:payment_date)
    @payments_user_revenue = payments.group(:shop).sum(:revenue)
    @payments_user_last_payment = payments.group(:shop).maximum(:payment_date)
  end
end
