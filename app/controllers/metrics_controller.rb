# TODO: Refactor this controller to not use so many instance variables
class MetricsController < ApplicationController
  before_action :authenticate_user!

  def show
    @filter = Metric::UserFilter.new(user: current_user, params: query_params)
    @tiles = @filter.tiles
    @selected_tile = @filter.tile
    @app_titles = current_user.app_titles(@filter.charge_type)
    Rails.logger.debug "@filter: #{@filter.to_param}"
    Rails.logger.debug "@params: #{params}"
    Rails.logger.debug "@query: #{query_params}"
  end

  private

  def query_params
    params.permit(
      :app,
      :chart,
      :date,
      :period,
      :charge_type
    )
  end
end
