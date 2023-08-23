# TODO: Convert to ActiveJob -> Sidekiq

class ImportWorker
  @queue = :import_queue

  def self.perform(current_user_id, filename = nil)
    return unless current_user_id

    current_user = User.find(current_user_id)
    last_calculated_metric = current_user.newest_metric_date || PaymentHistory.default_start_date

    if !filename.nil?
      PaymentHistory::CsvImporter.new(user: current_user, filename: filename).import!
    else
      PaymentHistory.import_partner_api(current_user, last_calculated_metric)
    end

    # Payments must be imported fully before metrics can be calculated
    Resque.enqueue(ImportMetricsWorker, current_user_id)
  rescue => e
    current_user.update(import: "Failed", import_status: 100)
    raise e
  end
end
