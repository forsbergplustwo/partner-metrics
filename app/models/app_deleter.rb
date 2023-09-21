class AppDeleter
  def initialize(user:, app_title:)
    @user = user
    @app_title = app_title
  end

  def delete
    delete_metrics
    delete_payments
    true
  end

  private

  def delete_metrics
    @user.metrics.where(app_title: @app_title).delete_all
  end

  def delete_payments
    @user.payments.where(app_title: @app_title).delete_all
  end
end
