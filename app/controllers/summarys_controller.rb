class SummarysController < ApplicationController
  before_action :authenticate_user!
  before_action :get_app_titles

  private

  def get_app_titles
    @app_titles = current_user.metrics.distinct.pluck(:app_title)
  end

  def summary_params
    params.permit(:selected_app)
  end
end
