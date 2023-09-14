class CalculateMetricsJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 0

  def perform(import:)
    import.calculate
  rescue => e
    import&.fail
    raise e
  end
end
