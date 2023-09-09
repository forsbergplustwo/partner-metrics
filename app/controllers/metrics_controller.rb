class MetricsController < ApplicationController
  before_action :authenticate_user!

  def show
    @filter = Metric::UserFilter.new(user: current_user, params: query_params)
    @tiles = @filter.tiles
    @selected_tile = @filter.tile
    @app_titles = current_user.app_titles(@filter.charge_type)
  end

  def destroy
    current_user.imports.delete_all
    current_user.metrics.delete_all
    current_user.payments.delete_all
    flash[:notice] = "Metrics reset!"
    redirect_to imports_path
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
