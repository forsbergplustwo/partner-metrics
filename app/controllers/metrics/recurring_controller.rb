class Metrics::RecurringController < MetricsController


  def index
  end

  private

  def charge_type
    "recurring_revenue"
  end
end
