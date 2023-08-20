class Metrics::AffiliateController < MetricsController
  def index
  end

  private

  def charge_type
    "affiliate_revenue"
  end
end
