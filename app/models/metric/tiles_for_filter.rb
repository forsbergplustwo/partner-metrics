class Metric::TilesForFilter
  OVERVIEW_TILES = [
    {"handle" => "total_revenue", "title" => "Total revenue", "calculation" => "sum", "metric_type" => nil, "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"handle" => "recurring_revenue", "title" => "Recurring revenue", "calculation" => "sum", "metric_type" => "recurring_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"handle" => "onetime_revenue", "title" => "One-time revenue", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"handle" => "affiliate_revenue", "title" => "Affiliate revenue", "calculation" => "sum", "metric_type" => "affiliate_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"handle" => "refund", "column" => "revenue", "title" => "Refunds", "calculation" => "sum", "metric_type" => "refund", "display" => "currency", "direction_good" => "down"},
    {"handle" => "avg_revenue_per_shop", "title" => "Avg. Revenue per User", "calculation" => "average", "metric_type" => nil, "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"}
  ].each(&:symbolize_keys!).freeze

  RECURRING_TILES = [
    {"handle" => "recurring_revenue", "title" => "Revenue", "calculation" => "sum", "metric_type" => "recurring_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"handle" => "number_of_shops", "title" => "Paying users", "calculation" => "sum", "metric_type" => "recurring_revenue", "column" => "number_of_shops", "display" => "number", "direction_good" => "up"},
    {"handle" => "recurring_avg_revenue_per_shop", "title" => "Avg. revenue per user", "calculation" => "average", "metric_type" => "recurring_revenue", "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"},
    {"handle" => "shop_churn", "title" => "User churn (30 day lag)", "calculation" => "average", "metric_type" => "recurring_revenue", "column" => "shop_churn", "display" => "percentage", "direction_good" => "down"},
    {"handle" => "revenue_churn", "title" => "Revenue churn (30 day lag)", "calculation" => "average", "metric_type" => "recurring_revenue", "column" => "revenue_churn", "display" => "percentage", "direction_good" => "down"},
    {"handle" => "lifetime_value", "title" => "Lifetime value (30 day lag)", "calculation" => "average", "metric_type" => "recurring_revenue", "column" => "lifetime_value", "display" => "currency", "direction_good" => "up"}
  ].each(&:symbolize_keys!).freeze

  ONETIME_TILES = [
    {"handle" => "onetime_revenue", "title" => "Revenue", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"handle" => "onetime_avg_revenue_per_charge", "title" => "Avg. revenue per sale", "calculation" => "average", "metric_type" => "onetime_revenue", "column" => "average_revenue_per_charge", "display" => "currency", "direction_good" => "up"},
    {"handle" => "onetime_avg_revenue_per_shop", "title" => "Avg. revenue per user", "calculation" => "average", "metric_type" => "onetime_revenue", "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"},
    {"handle" => "onetime_number_of_charges", "title" => "Number of sales", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "number_of_charges", "display" => "number", "direction_good" => "up"},
    {"handle" => "repeat_customers", "title" => "Repeat customers", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "repeat_customers", "display" => "number", "direction_good" => "up"},
    {"handle" => "repeat_vs_new_customers", "title" => "Repeat vs new customers", "calculation" => "average", "metric_type" => "onetime_revenue", "column" => "repeat_vs_new_customers", "display" => "percentage", "direction_good" => "up"}
  ].each(&:symbolize_keys!).freeze

  AFFILIATE_TILES = [
    {"handle" => "affiliate_revenue", "title" => "Revenue", "calculation" => "sum", "metric_type" => "affiliate_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"handle" => "affiliate_number_of_charges", "title" => "Number of affiliates", "calculation" => "sum", "metric_type" => "affiliate_revenue", "column" => "number_of_charges", "display" => "number", "direction_good" => "up"},
    {"handle" => "affiliate_avg_revenue_per_shop", "title" => "Avg. revenue per user", "calculation" => "average", "metric_type" => "affiliate_revenue", "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"}
  ].each(&:symbolize_keys!).freeze

  def initialize(filter:)
    @filter = filter
  end

  def tiles
    build_tiles
  end

  private

  def build_tiles
    tiles_for_charge_type.collect do |tile|
      Metric::TileForFilter.new(filter: @filter, tile_config: tile)
    end
  end

  def tiles_for_charge_type
    case @filter.charge_type
    when "recurring_revenue"
      RECURRING_TILES
    when "onetime_revenue"
      ONETIME_TILES
    when "affiliate_revenue"
      AFFILIATE_TILES
    else
      OVERVIEW_TILES
    end
  end
end
