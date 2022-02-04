class Metric < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true

  OVERVIEW_TILES = [
    {"type" => "total_revenue", "title" => "Total Revenue", "calculation" => "sum", "metric_type" => "any", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "recurring_revenue", "title" => "Recurring Revenue", "calculation" => "sum", "metric_type" => "recurring_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "onetime_revenue", "title" => "One-Time Revenue", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "affiliate_revenue", "title" => "Affiliate Revenue", "calculation" => "sum", "metric_type" => "affiliate_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "refund", "column" => "revenue", "title" => "Refunds", "calculation" => "sum", "metric_type" => "refund", "display" => "currency", "direction_good" => "down"},
    {"type" => "avg_revenue_per_shop", "title" => "Avg. Revenue per User", "calculation" => "average", "metric_type" => "any", "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"},
  ].freeze

  RECURRING_TILES = [
    {"type" => "recurring_revenue", "title" => "Revenue", "calculation" => "sum", "metric_type" => "recurring_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "number_of_shops", "title" => "Paying Users", "calculation" => "sum", "metric_type" => "recurring_revenue", "column" => "number_of_shops", "display" => "number", "direction_good" => "up"},
    {"type" => "recurring_avg_revenue_per_shop", "title" => "Avg. Revenue per User", "calculation" => "average", "metric_type" => "recurring_revenue", "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"},
    {"type" => "shop_churn", "title" => "User Churn (30 Day Lag)", "calculation" => "time_average", "metric_type" => "recurring_revenue", "column" => "shop_churn", "display" => "percentage", "direction_good" => "down"},
    {"type" => "revenue_churn", "title" => "Revenue Churn (30 Day Lag)", "calculation" => "time_average", "metric_type" => "recurring_revenue", "column" => "revenue_churn", "display" => "percentage", "direction_good" => "down"},
    {"type" => "lifetime_value", "title" => "Lifetime Value (30 Day Lag)", "calculation" => "time_average", "metric_type" => "recurring_revenue", "column" => "lifetime_value", "display" => "currency", "direction_good" => "up"},
  ].freeze

  ONETIME_TILES = [
    {"type" => "onetime_revenue", "title" => "Revenue", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "onetime_avg_revenue_per_charge", "title" => "Avg. Revenue per Sale", "calculation" => "average", "metric_type" => "onetime_revenue", "column" => "average_revenue_per_charge", "display" => "currency", "direction_good" => "up"},
    {"type" => "onetime_avg_revenue_per_shop", "title" => "Avg. Revenue per User", "calculation" => "average", "metric_type" => "onetime_revenue", "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"},
    {"type" => "onetime_number_of_charges", "title" => "Number of Sales", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "number_of_charges", "display" => "number", "direction_good" => "up"},
    {"type" => "repeat_customers", "title" => "Repeat Customers", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "repeat_customers", "display" => "number", "direction_good" => "up"},
    {"type" => "repeat_vs_new_customers", "title" => "Repeat vs New Customers", "calculation" => "average", "metric_type" => "onetime_revenue", "column" => "repeat_vs_new_customers", "display" => "percentage", "direction_good" => "up"},
  ].freeze

  AFFILIATE_TILES = [
    {"type" => "affiliate_revenue", "title" => "Revenue", "calculation" => "sum", "metric_type" => "affiliate_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "affiliate_number_of_charges", "title" => "Number of Affiliates", "calculation" => "sum", "metric_type" => "affiliate_revenue", "column" => "number_of_charges", "display" => "number", "direction_good" => "up"},
    {"type" => "affiliate_avg_revenue_per_shop", "title" => "Avg. Revenue per User", "calculation" => "average", "metric_type" => "affiliate_revenue", "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"},
  ].freeze

  MONTHS_AGO = [1, 2, 3, 6, 12].freeze

  class << self
    def calculate_value(current_user, type, period)
      value = if type["metric_type"] == "any"
        where(user_id: current_user.id)
      else
        where(user_id: current_user.id, charge_type: type["metric_type"])
      end
      value = if type["calculation"] == "sum"
        value.sum(type["column"])
      elsif type["calculation"] == "time_average"
        time_average(value, type["column"], period)
      else
        value.average(type["column"])
      end
      value
    end

    def calculate_change(current_user, type, previous_metrics, period)
      if type["metric_type"] == "any"
        current = where(user_id: current_user.id)
        previous = previous_metrics
      else
        current = where(user_id: current_user.id, charge_type: type["metric_type"])
        previous = previous_metrics.where(charge_type: type["metric_type"])
      end
      if type["calculation"] == "sum"
        current = current.sum(type["column"])
        previous = previous.sum(type["column"])
      elsif type["calculation"] == "time_average"
        current = time_average(current, type["column"], period)
        previous = time_average(previous, type["column"], period)
      else
        current = current.average(type["column"]) || 0
        previous = previous.average(type["column"]) || 0
      end
      change = current.blank? || previous.blank? ? 0 : (current.to_f / previous * 100) - 100
      change
    end

    def get_chart_data(current_user, date, period, type, app_title)
      date = Date.parse(date)
      metrics = if app_title.blank?
        where(user_id: current_user.id)
      else
        where(user_id: current_user.id, app_title: app_title)
      end
      app_title_count = metrics.pluck(:app_title).uniq.size
      if type["metric_type"] == "any"
        first_date = metrics.order("metric_date").first.metric_date
        group_options = group_options(date, first_date, period)
        metrics = metrics.group(group_options, {restrict: true})
      else
        first_date = metrics.where(charge_type: type["metric_type"]).order("metric_date").first.metric_date
        group_options = group_options(date, first_date, period)
        metrics = metrics.where(charge_type: type["metric_type"]).group(group_options, restrict: true)
      end
      metrics = if type["calculation"] == "sum"
        metrics.sum(type["column"])
      elsif type["calculation"] == "time_average"
        time_average(metrics, type["column"], period, app_title_count)
      else
        metrics.average(type["column"])
      end
      group_options[:metric_date].each do |g|
        gf = g.first.to_date
        metrics[gf.to_s] = 0 if metrics[gf.to_s].blank?
      end
      metrics.sort_by { |h| h[0].to_datetime }
      metrics
    end

    def group_options(date, first_date, period)
      counter_date = date
      group_options = {metric_date: {}}
      until counter_date < first_date
        group_options[:metric_date][counter_date] = counter_date.beginning_of_day - period.days + 1.day..counter_date.end_of_day
        counter_date -= period.days
      end
      group_options
    end

    def calculate_value_period_ago(current_user, month_ago, date, period, type, app_title)
      date -= (period * month_ago).days
      last_date = date - period.days + 1.day
      value = if app_title.blank?
        where(user_id: current_user.id, metric_date: last_date..date)
      else
        where(user_id: current_user.id, metric_date: last_date..date, app_title: app_title)
      end
      if type["metric_type"] != "any"
        value = value.where(charge_type: type["metric_type"])
      end
      if type["calculation"] == "sum"
        value.sum(type["column"])
      elsif type["calculation"] == "time_average"
        time_average(value, type["column"], period)
      else
        value.average(type["column"])
      end
    end

    private

    def time_average(value, column, period, app_title_count = nil)
      app_title_count = value.pluck(:app_title).uniq.size if app_title_count.nil?
      value.sum(column) / (period * app_titles)
    end
  end
end
