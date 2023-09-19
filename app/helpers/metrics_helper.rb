module MetricsHelper
  def revenue_per_partial_for(charge_type)
    if charge_type.blank?
      "metrics/revenue_per"
    else
      "metrics/#{charge_type}/revenue_per"
    end
  end

  def metric_display_value(selected_chart_display, value)
    case selected_chart_display
    when :number
      number_with_delimiter(value, delimiter: ",")
    when :percentage
      number_to_percentage(value, precision: 2)
    else
      number_to_currency_with_precision(value)
    end
  end

  def number_to_currency_with_precision(value)
    precision = (value.to_i < 100) ? 2 : 0
    number_to_currency(value, precision: precision)
  end

  def number_to_percentage_with_precision(value)
    precision = (value < 10) ? 2 : 1
    percentage = number_to_percentage(value, precision: precision)
    (value > 0) ? "+" + percentage : percentage
  end

  def metric_change_color(metric_change, positive_change_is_good)
    if positive_change_is_good
      return :success if metric_change > 0.01
      return :critical if metric_change < -0.01
    else
      return :success if metric_change < -0.01
      return :critical if metric_change > 0.01
    end
    :subdued
  end

  def show_averages(period, tile)
    types = [:average, :lifetime_value, :repeat_customers]
    !types.include?(tile.handle) || tile.calculation != :average
  end

  def filter_periods
    Metric::PERIODS.map { |p| ["#{p} days", p] }
  end

  def period_ago_in_words(date, period, period_ago)
    past_date = date - (period * period_ago).days
    raw_text = distance_of_time_in_words(date, past_date)
    clean_text = raw_text.gsub("about", "").gsub("almost", "")
    "#{clean_text} ago"
  end

  def period_word(period)
    case period
    when 30 then "Month"
    when 7 then "Week"
    else "Day"
    end
  end

  def metric_chart_url(tile_type, date, period, app)
    url_for(
      action: action_name,
      date: date,
      period: period,
      chart: tile_type,
      app: app,
      anchor: "top"
    )
  end

  def metrics_chart_options
    {
      download: true,
      library: {
        pointSize: 6,
        isStacked: false,
        backgroundColor: "transparent",
        animation: {
          startup: true,
          duration: 600,
          easing: "inAndOut"
        },
        lineWidth: 3,
        colors: ["#5a24cd", "#7945e3"],
        explorer: {
          keepInBounds: true,
          axis: "horizontal",
          maxZoomIn: 0.5,
          maxZoomOut: 1,
          zoomDelta: 1.1
        },
        vAxis: {
          format: "short",
          gridlines: {
            color: "#F1F2F4"
          }
        },
        timeline: {
          tooltipDateFormat: "MMM d, yyyy"
        },
        hAxis: {
          format: "MMM d, y"
        },
        chartArea: {
          width: "100%",
          height: "80%",
          left: "5%"
        },
        focusTarget: "category",
        series: {
          "1": {
            visibleInLegend: false,
            lineWidth: 0,
            areaOpacity: 0
          }
        }
      }
    }
  end
end
