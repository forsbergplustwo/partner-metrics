class ImportMetricsJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 0

  def perform(import_id:)
    import = Import.find(import_id)
    return unless import

    PaymentHistory.calculate_metrics(import: import)
    import.completed!
  rescue => e
    import&.failed!
    raise e
  end
end
