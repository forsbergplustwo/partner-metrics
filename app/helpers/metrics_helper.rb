module MetricsHelper
  def number_to_currency_with_precision(value)
    precision = (value < 100) ? 2 : 0
    number_to_currency(value, precision: precision)
  end

  def number_to_percentage_with_precision(value)
    precision = (value < 10) ? 2 : 1
    percentage = number_to_percentage(value, precision: precision)
    (value > 0) ? "+" + percentage : percentage
  end

  def metric_change_color(metric_change, direction_good)
    if direction_good == "up"
      if metric_change > 0.01
        "text-success"
      elsif metric_change < -0.01
        "text-danger"
      else
        ""
      end
    elsif metric_change < -0.01
      "text-success"
    elsif metric_change > 0.01
      "text-danger"
    else
      ""
    end
  end

  def show_averages(period, type)
    if type["calculation"] == "average" || type["type"] == "lifetime_value" || type["type"] == "repeat_customers"
      false
    else
      true
    end
  end

  def periods_ago(period)
    [1, 2, 3, 6, 12]
  end

  def period_word(period)
    if period == 30
      "Month"
    elsif period == 7
      "Week"
    else
      "Day"
    end
  end
end
