class ImportPaymentsJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 0

  def perform(import:)
    import.import
  rescue => e
    import&.failed!
    raise e
  end
end
