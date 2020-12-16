class ImportMetricsWorker
  @queue = :import_queue

  def self.perform(current_user_id)
    return unless current_user_id
    current_user = User.find(current_user_id)
    PaymentHistory.calculate_metrics(current_user)
  rescue => e
    current_user.update(import: "Failed", import_status: 100)
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    raise e
  end
end
