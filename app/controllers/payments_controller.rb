class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @payments = []
  end

  # TODO: Refactor -> This one is different from the others and needs re-thinking separately
  # def index
  #   if params["selected_app"].blank?
  #     payments = current_user.payments
  #     metrics = current_user.metrics
  #   else
  #     @selected_app = params["selected_app"]
  #     payments = current_user.payments.where(app_title: params["selected_app"])
  #     metrics = current_user.metrics.where(app_title: params["selected_app"])
  #   end
  #   @payments_count = payments.group_by_month(:payment_date, reverse: true, last: 36).count
  #   @payments_revenue = payments.group_by_month(:payment_date, reverse: true, last: 36).sum(:revenue)
  #   @metrics_revenue_churn = metrics.group_by_month(:metric_date, reverse: true, last: 36).average(:revenue_churn)
  #   @metrics_user_churn = metrics.group_by_month(:metric_date, reverse: true, last: 36).average(:shop_churn)
  #   @payments_users = payments.group(:shop).count(:payment_date)
  #   @payments_user_revenue = payments.group(:shop).sum(:revenue)
  #   @payments_user_last_payment = payments.group(:shop).maximum(:payment_date)
  # end
end
