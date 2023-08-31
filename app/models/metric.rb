class Metric < ApplicationRecord
  belongs_to :user

  PERIODS = [7, 28, 29, 30, 31, 90, 180, 365].freeze

  MONTHS_AGO = [1, 2, 3, 6, 12].freeze

  class << self
    def by_date_and_period(date:, period:)
      previous_period = date - period.days + 1
      where(metric_date: previous_period.beginning_of_day..date.end_of_day)
    end

    def calculate_value(calculation, column)
      (calculation == "sum") ? sum(column) : average(column)
    end

    def chart_data(date, period, calculation, column)
      # Get the first date of metrics, so we know how far back to go
      first_date = minimum("metric_date")
      return [] unless first_date

      # Build the date ranges, and group the metrics by date
      group_options = group_options(date, first_date, period)
      metrics = group(group_options, {restrict: true})

      # Calculate the metrics for each date range
      metrics = (calculation == "sum") ? metrics.sum(column) : metrics.average(column)

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
        group_options[:metric_date][counter_date] = (counter_date.beginning_of_day - period.days + 1.day)..counter_date.end_of_day
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
