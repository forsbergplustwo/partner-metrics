class MetricsController < ApplicationController
  before_action :authenticate_user!

  def show
    @filter = Metric::TilesFilter.new(user: current_user, params: query_params)

    @app_titles = @filter.app_titles
    @tiles = @filter.tiles
    @selected_tile = @filter.selected_tile
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
