class Public::SmiirlController < ActionController::API
  before_action :set_integration

  def show
    unless @integration.enabled?
      head :not_found and return
    end

    count_value = compute_count(@integration)
    render json: {count: count_value}
  end

  private

  def set_integration
    @integration = SmiirlIntegration.find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def compute_count(integration)
    user = integration.user
    return 0 if user.blank?

    case integration.metric_type
    when "paying_users_30d"
      user.paying_users_30d.to_i
    else # "total_revenue_30d"
      user.total_revenue_30d.to_i
    end
  end
end
