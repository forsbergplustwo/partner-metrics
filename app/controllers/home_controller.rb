class HomeController < ApplicationController
  def index
    if current_user.present?
      redirect_to metrics_path
    end
  end

  # TODO: Find a better place for this
  def app_store_analytics
  end
end
