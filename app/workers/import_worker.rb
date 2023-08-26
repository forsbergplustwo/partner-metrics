# TODO: Convert to ActiveJob -> Sidekiq

class ImportWorker
  @queue = :import_queue

  def self.perform(current_user_id, filename = nil)
    return unless current_user_id

    user = User.find(current_user_id)

    if !filename.nil?
      PaymentHistory::CsvImporter.new(user: user, filename: filename).import!
    else
      PaymentHistory::ApiImporter.new(user: user).import!
    end

    # Payments must be imported fully before metrics can be calculated
    Resque.enqueue(ImportMetricsWorker, user.id)
  rescue => e
    user.update(import: "Failed", import_status: 100)
    raise e
  end
end
