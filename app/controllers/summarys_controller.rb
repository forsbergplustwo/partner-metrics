# frozen_string_literal: true

class SummarysController < ApplicationController
  before_action :authenticate_user!
  before_action :app_titles

  private

  def app_titles
    @app_titles = current_user.metrics.distinct.pluck(:app_title)
  end

  def summary_params
    params.permit(:selected_app)
  end
end
