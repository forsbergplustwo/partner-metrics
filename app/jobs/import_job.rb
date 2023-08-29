class ImportJob < ApplicationJob
  include Sidekiq::Job

  queue_as :default
  sidekiq_options retry: 0

  def perform(user_id:, import_type: nil)
    user = User.find(user_id)

    if !import_type.nil? && import_type == :csv
      PaymentHistory::CsvImporter.new(user: user).import!
    else
      PaymentHistory::ApiImporter.new(user: user).import!
    end

    # Payments must be imported fully before metrics can be calculated
    ImportMetricsJob.perform_later(user_id: user.id)
  rescue => e
    user&.update(import: "Failed", import_status: 100)
    raise e
  end
end
