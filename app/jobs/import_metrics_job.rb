class ImportMetricsJob < ApplicationJob
  queue_as :default

  def perform(current_user_id)
    return unless current_user_id
    current_user = User.find(current_user_id)

    PaymentHistory.calculate_metrics(current_user)
  rescue => e
    current_user&.update(import: "Failed", import_status: 100)
    raise e
  end
end
