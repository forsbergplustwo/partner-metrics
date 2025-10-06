class SmiirlIntegrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_smiirl_integration

  def edit
  end

  def update
    if @smiirl_integration.update(smiirl_integration_params)
      redirect_to smiirl_integration_path, notice: "Smiirl integration updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def rotate_token
    @smiirl_integration.rotate_token!
    redirect_to smiirl_integration_path, notice: "Smiirl integration token rotated."
  end

  private

  def set_smiirl_integration
    @smiirl_integration = current_user.smiirl_integration || current_user.build_smiirl_integration
  end

  def smiirl_integration_params
    params.require(:smiirl_integration).permit(:enabled, :metric_type)
  end
end
