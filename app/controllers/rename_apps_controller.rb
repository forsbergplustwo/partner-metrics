class RenameAppsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_app_titles

  def new
  end

  def create
    app_renamer = AppRenamer.new(
      user: current_user,
      from: rename_app_params[:from],
      to: rename_app_params[:to]
    )
    if app_renamer.rename!
      redirect_to rename_apps_path, notice: "App renamed successfully"
    else
      flash.now[:error] = "App rename failed"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def get_app_titles
    @app_titles = current_user.metrics.distinct.pluck(:app_title)
  end

  def rename_app_params
    params.require(:rename_app).permit(:from, :to)
  end
end
