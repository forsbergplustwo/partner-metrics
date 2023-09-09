class Summary
  def initialize(user:, selected_app: nil)
    @user = user
    @selected_app = selected_app
  end

  private

  def payments
    @payments ||= @user.payments.by_optional_app_title(@selected_app)
  end

  def metrics
    @metrics ||= @user.metrics.by_optional_app_title(@selected_app)
  end
end
