module Metric::TilesConfig
  OVERVIEW_TILES = [
    {
      handle: :total_revenue,
      calculation: :sum,
      charge_type: nil,
      column: :revenue,
      display: :currency,
      positive_change_is_good: true
    },
    {
      handle: :recurring_revenue,
      calculation: :sum,
      charge_type: :recurring_revenue,
      column: :revenue,
      display: :currency,
      positive_change_is_good: true
    },
    {
      handle: :onetime_revenue,
      calculation: :sum,
      charge_type: :onetime_revenue,
      column: :revenue,
      display: :currency,
      positive_change_is_good: true
    },
    {
      handle: :affiliate_revenue,
      calculation: :sum,
      charge_type: :affiliate_revenue,
      column: :revenue,
      display: :currency,
      positive_change_is_good: true
    },
    {
      handle: :refunds,
      column: :revenue,
      calculation: :sum,
      charge_type: :refund,
      display: :currency,
      positive_change_is_good: false
    },
    {
      handle: :avg_revenue_per_shop,
      calculation: :average,
      charge_type: nil,
      column: :average_revenue_per_shop,
      display: :currency,
      positive_change_is_good: true
    }
  ].freeze

  RECURRING_TILES = [
    {
      handle: :recurring_revenue,
      calculation: :sum,
      charge_type: :recurring_revenue,
      column: :revenue,
      display: :currency,
      positive_change_is_good: true
    },
    {
      handle: :paying_shops,
      calculation: :sum,
      charge_type: :recurring_revenue,
      column: :number_of_shops,
      display: :number,
      positive_change_is_good: true
    },
    {
      handle: :recurring_avg_revenue_per_shop,
      calculation: :average,
      charge_type: :recurring_revenue,
      column: :average_revenue_per_shop,
      display: :currency,
      positive_change_is_good: true
    },
    {
      handle: :shop_churn,
      calculation: :average,
      charge_type: :recurring_revenue,
      column: :shop_churn,
      display: :percentage,
      positive_change_is_good: false
    },
    {
      handle: :revenue_churn,
      calculation: :average,
      charge_type: :recurring_revenue,
      column: :revenue_churn,
      display: :percentage,
      positive_change_is_good: false
    },
    {
      handle: :lifetime_value,
      calculation: :average,
      charge_type: :recurring_revenue,
      column: :lifetime_value,
      display: :currency,
      positive_change_is_good: true
    }
  ].freeze

  ONETIME_TILES = [
    {
      handle: :onetime_revenue,
      calculation: :sum,
      charge_type: :onetime_revenue,
      column: :revenue,
      display: :currency,
      positive_change_is_good: true
    },
    {
      handle: :onetime_avg_revenue_per_charge,
      calculation: :average,
      charge_type: :onetime_revenue,
      column: :average_revenue_per_charge,
      display: :currency,
      positive_change_is_good: true
    },
    {
      handle: :onetime_avg_revenue_per_shop,
      calculation: :average,
      charge_type: :onetime_revenue,
      column: :average_revenue_per_shop,
      display: :currency,
      positive_change_is_good: true
    },
    {
      handle: :number_of_sales,
      calculation: :sum,
      charge_type: :onetime_revenue,
      column: :number_of_charges,
      display: :number,
      positive_change_is_good: true
    },
    {
      handle: :repeat_customers,
      calculation: :sum,
      charge_type: :onetime_revenue,
      column: :repeat_customers,
      display: :number,
      positive_change_is_good: true
    },
    {
      handle: :repeat_vs_new_customers,
      calculation: :average,
      charge_type: :onetime_revenue,
      column: :repeat_vs_new_customers,
      display: :percentage,
      positive_change_is_good: true
    }
  ].freeze

  AFFILIATE_TILES = [
    {
      handle: :affiliate_revenue,
      calculation: :sum,
      charge_type: :affiliate_revenue,
      column: :revenue,
      display: :currency,
      positive_change_is_good: true
    },
    {
      handle: :affiliate_number_of_charges,
      calculation: :sum,
      charge_type: :affiliate_revenue,
      column: :number_of_charges,
      display: :number,
      positive_change_is_good: true
    },
    {
      handle: :affiliate_avg_revenue_per_shop,
      calculation: :average,
      charge_type: :affiliate_revenue,
      column: :average_revenue_per_shop,
      display: :currency,
      positive_change_is_good: true
    }
  ].freeze
end
