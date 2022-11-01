class ImportWorker
  @queue = :import_queue

  def self.perform(current_user_id, filename = nil)
    return unless current_user_id
    current_user = User.find(current_user_id)
    last_calculated_metric = current_user.metrics.maximum("metric_date")
    last_calculated_metric_date = last_calculated_metric.presence || 48.months.ago.to_date
    if !filename.nil?
      Rails.logger.info("CSV IMPORT")
      PaymentHistory.import_csv(current_user, last_calculated_metric_date, filename)
    else
      Rails.logger.info("API IMPORT")
      PaymentHistory.import_partner_api(current_user, last_calculated_metric_date)
    end
    Resque.enqueue(ImportMetricsWorker, current_user.id)
  rescue => e
    current_user.update(import: "Failed", import_status: 100)
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    raise e
  end
end
