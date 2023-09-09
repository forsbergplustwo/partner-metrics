class RenameAppsController < ApplicationController
  before_action :authenticate_user!

  def new
    @apps = current_user.metrics.distinct.pluck(:app_title)
    Rails.logger.info(@apps)
  end

  def create
    from_name = rename_app_params[:from]
    to_name = rename_app_params[:to]
    if from_name.present? && to_name.present? && from_name != to_name
      current_user.metrics.where(app_title: from_name).update_all(app_title: to_name)
      current_user.payments.where(app_title: from_name).update_all(app_title: to_name)
      redirect_to rename_apps_path, notice: "App renamed successfully"
    else
      flash.now[:error] = "App rename failed"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def rename_app_params
    params.require(:rename_app).permit(:from, :to)
  end
end
