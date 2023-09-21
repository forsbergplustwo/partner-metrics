class HomeController < ApplicationController
  def index
    if current_user.present?
      redirect_to metrics_path
    end
  end
end
