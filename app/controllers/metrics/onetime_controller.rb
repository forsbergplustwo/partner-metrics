class Metrics::OnetimeController < MetricsController
  def index
  end

  private

  def charge_type
    "one_time_revenue"
  end
end
