class DeleteAppsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_app_titles

  def new
  end

  def create
    app = delete_app_params[:app_title]
    app_deleter = AppDeleter.new(
      user: current_user,
      app_title: app
    )
    if @app_titles.include?(app) && app_deleter.delete
      redirect_to delete_apps_path, notice: "App deleted successfully"
    else
      flash[:alert] = "App delete failed"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def get_app_titles
    @app_titles = current_user.metrics.distinct.pluck(:app_title)
  end

  def delete_app_params
    params.require(:delete_apps).permit(:app_title)
  end
end
