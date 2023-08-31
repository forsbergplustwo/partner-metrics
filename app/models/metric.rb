class Metric < ApplicationRecord
  belongs_to :user

  PERIODS = [7, 28, 29, 30, 31, 90, 180, 365].freeze

  METRICS_TILES = [
    {"type" => "total_revenue", "title" => "Total revenue", "calculation" => "sum", "metric_type" => nil, "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "recurring_revenue", "title" => "Recurring revenue", "calculation" => "sum", "metric_type" => "recurring_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "onetime_revenue", "title" => "One-time revenue", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "affiliate_revenue", "title" => "Affiliate revenue", "calculation" => "sum", "metric_type" => "affiliate_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "refund", "column" => "revenue", "title" => "Refunds", "calculation" => "sum", "metric_type" => "refund", "display" => "currency", "direction_good" => "down"},
    {"type" => "avg_revenue_per_shop", "title" => "Avg. Revenue per User", "calculation" => "average", "metric_type" => nil, "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"}
  ].freeze

  RECURRING_TILES = [
    {"type" => "recurring_revenue", "title" => "Revenue", "calculation" => "sum", "metric_type" => "recurring_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "number_of_shops", "title" => "Paying users", "calculation" => "sum", "metric_type" => "recurring_revenue", "column" => "number_of_shops", "display" => "number", "direction_good" => "up"},
    {"type" => "recurring_avg_revenue_per_shop", "title" => "Avg. revenue per user", "calculation" => "average", "metric_type" => "recurring_revenue", "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"},
    {"type" => "shop_churn", "title" => "User churn (30 day lag)", "calculation" => "average", "metric_type" => "recurring_revenue", "column" => "shop_churn", "display" => "percentage", "direction_good" => "down"},
    {"type" => "revenue_churn", "title" => "Revenue churn (30 day lag)", "calculation" => "average", "metric_type" => "recurring_revenue", "column" => "revenue_churn", "display" => "percentage", "direction_good" => "down"},
    {"type" => "lifetime_value", "title" => "Lifetime value (30 day lag)", "calculation" => "average", "metric_type" => "recurring_revenue", "column" => "lifetime_value", "display" => "currency", "direction_good" => "up"}
  ].freeze

  ONETIME_TILES = [
    {"type" => "onetime_revenue", "title" => "Revenue", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "onetime_avg_revenue_per_charge", "title" => "Avg. revenue per sale", "calculation" => "average", "metric_type" => "onetime_revenue", "column" => "average_revenue_per_charge", "display" => "currency", "direction_good" => "up"},
    {"type" => "onetime_avg_revenue_per_shop", "title" => "Avg. revenue per user", "calculation" => "average", "metric_type" => "onetime_revenue", "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"},
    {"type" => "onetime_number_of_charges", "title" => "Number of sales", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "number_of_charges", "display" => "number", "direction_good" => "up"},
    {"type" => "repeat_customers", "title" => "Repeat customers", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "repeat_customers", "display" => "number", "direction_good" => "up"},
    {"type" => "repeat_vs_new_customers", "title" => "Repeat vs new customers", "calculation" => "average", "metric_type" => "onetime_revenue", "column" => "repeat_vs_new_customers", "display" => "percentage", "direction_good" => "up"}
  ]

  AFFILIATE_TILES = [
    {"type" => "affiliate_revenue", "title" => "Revenue", "calculation" => "sum", "metric_type" => "affiliate_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "affiliate_number_of_charges", "title" => "Number of affiliates", "calculation" => "sum", "metric_type" => "affiliate_revenue", "column" => "number_of_charges", "display" => "number", "direction_good" => "up"},
    {"type" => "affiliate_avg_revenue_per_shop", "title" => "Avg. revenue per user", "calculation" => "average", "metric_type" => "affiliate_revenue", "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"}
  ].freeze

  MONTHS_AGO = [1, 2, 3, 6, 12].freeze

  class << self
    def charge_type_for(name)
      case name
      when "recurring"
        "recurring_revenue"
      when "onetime"
        "onetime_revenue"
      when "affiliate"
        "affiliate_revenue"
      end
    end

    def tiles_for(name)
      "Metric::#{name.upcase}_TILES".constantize
    end

    def calculate_value(current_user, type)
      value = if type["metric_type"].nil?
        where(user_id: current_user.id)
      else
        where(user_id: current_user.id, charge_type: type["metric_type"])
      end
      if type["calculation"] == "sum"
        value.sum(type["column"])
      else
        value.average(type["column"])
      end
    end

    def for_range_and_query(date:, period:, app_title: nil, charge_type: nil)
      previous_period = date - period.days + 1

      metrics = where(metric_date: previous_period..date)
      metrics = metrics.where(app_title: app_title) if app_title.present?
      metrics = metrics.where(charge_type: charge_type) if charge_type.present?
      metrics
    end

    def calculate_change(current_user, type, previous_metrics)
      if type["metric_type"].nil?
        current = where(user_id: current_user.id)
        previous = previous_metrics
      else
        current = where(user_id: current_user.id, charge_type: type["metric_type"])
        previous = previous_metrics.where(charge_type: type["metric_type"])
      end
      if type["calculation"] == "sum"
        current = current.sum(type["column"])
        previous = previous.sum(type["column"])
      else
        current = current.average(type["column"]) || 0
        previous = previous.average(type["column"]) || 0
      end
      (current.blank? || previous.blank?) ? 0 : (current.to_f / previous * 100) - 100
    end

    def get_chart_data(type, date, period, app_title)
      # self keeps the scope of current user
      metrics = self
      metrics = metrics.where(app_title: app_title) unless app_title.blank?
      metrics = metrics.where(charge_type: type["metric_type"]) unless type["metric_type"].blank?

      # Get the first date of metrics, so we know how far back to go
      first_date = metrics.maximum("metric_date")
      return [] unless first_date

      # Build the date ranges, and group the metrics by date
      group_options = group_options(date, first_date, period)
      metrics = metrics.group(group_options, {restrict: true})

      # Calculate the metrics for each date range
      metrics = (type["calculation"] == "sum") ? metrics.sum(type["column"]) : metrics.average(type["column"])

      # Fill in dates with no metrics with 0
      group_options[:metric_date].keys.each { |k| metrics[k.to_s] ||= 0 }

      # Sort the dates and return the metrics
      metrics.sort_by { |h| h[0].to_datetime }
    end

    # Build a hash of dates containing date ranges,
    # for each period between the first date and the date selected
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
      value = value.where(charge_type: type["metric_type"]) unless type["metric_type"].blank?
      if type["calculation"] == "sum"
        value.sum(type["column"])
      else
        value.average(type["column"])
      end
    end
  end
end
