class ImportJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 0

  def perform(import:)
    if import.source == Import::IMPORT_FILE_SOURCE
      Payment::CsvImporter.new(import: import).import!
    else
      Payment::ApiImporter.new(import: import).import!
    end
    import.calculating!
    # Payments must be imported fully before metrics can be calculated
    ImportMetricsJob.perform_later(import_id: import.id)
  rescue => e
    import&.failed!
    raise e
  end
end
