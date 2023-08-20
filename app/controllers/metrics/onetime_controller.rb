class Metrics::OnetimeController < MetricsController
  def index
  end

  private

  def charge_type
    "onetime_revenue"
  end
end
