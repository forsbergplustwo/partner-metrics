class Public::SmiirlController < ActionController::API
  before_action :set_integration

  def show
    unless @integration.enabled?
      head :not_found and return
    end

    count_value = compute_count(@integration)
    render json: { count: count_value }
  end

  private

  def set_integration
    @integration = SmiirlIntegration.find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def compute_count(integration)
    user = integration.user
    end_date = user.newest_metric_date_or_today
    start_date = end_date - 29.days

    case integration.metric_type
    when "total_revenue_30d"
      # Sum revenue from metrics for last 30 days, all charge types that are displayable
      user.metrics
        .where(metric_date: start_date..end_date)
        .where(charge_type: Metric::CHARGE_TYPES - ["refund"])
        .sum(:revenue).to_i
    else # "paying_users_30d"
      # Count distinct shops with positive revenue over last 30 days
      user.payments
        .where(payment_date: start_date..end_date)
        .where(charge_type: Metric::CHARGE_TYPES - ["refund"])
        .where("revenue > 0")
        .distinct
        .count(:shop)
    end
  end
end

