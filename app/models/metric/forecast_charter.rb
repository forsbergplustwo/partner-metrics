require "prophet-rb"
require "rover"

class Metric::ForecastCharter
  FORECAST_PERIODS = 6
  FREQUENCIES = {
    monthly: "MS"
  }.freeze

  def initialize(chart_data:)
    @chart_data = chart_data
  end

  def chart_data
    return [] if insufficient_data?

    dataframe = dataframe_from_chart_data
    prophet = prophet_for(dataframe)
    future_dataframe = future_dataframe_from(prophet)

    generate_forecast_data(prophet, future_dataframe, @chart_data.keys.last)
  end

  private

  def insufficient_data?
    @chart_data.size < 10
  end

  def dataframe_from_chart_data
    Rover::DataFrame.new({"ds" => @chart_data.keys, "y" => @chart_data.values})
  end

  def prophet_for(dataframe)
    Prophet.new.fit(dataframe)
  end

  def future_dataframe_from(prophet)
    prophet.make_future_dataframe(periods: FORECAST_PERIODS, freq: FREQUENCIES[:monthly])
  end

  def generate_forecast_data(prophet, future_dataframe, last_date)
    forecast = prophet.predict(future_dataframe)
    data = []
    forecast["ds"].each_with_index do |date, index|
      data << [date, forecast["yhat"][index]] if date > last_date
    end
    data
  end
end
