class CalculateMetricsJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 0

  def perform(import:)
    import.calculate
  rescue => e
    import&.failed!
    raise e
  end
end
