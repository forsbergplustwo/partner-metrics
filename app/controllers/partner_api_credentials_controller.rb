class PartnerApiCredentialsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_partner_api_credential, only: %i[edit update destroy]

  def new
    if current_user.partner_api_credential.present?
      redirect_to_edit and return
    else
      @partner_api_credential = current_user.build_partner_api_credential
    end
  end

  def edit
  end

  def create
    @partner_api_credential = current_user.build_partner_api_credential(partner_api_credential_params)

    if @partner_api_credential.save
      redirect_to edit_partner_api_credential_path(@partner_api_credential), notice: "Partner api credential was successfully created."
    else
      render :new, status: :unprocessable_entity, notice: "Partner api credential was not created."
    end
  end

  def update
    if @partner_api_credential.update(partner_api_credential_params)
      redirect_to edit_partner_api_credential_path(@partner_api_credential), notice: "Partner api credential was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @partner_api_credential.destroy
    redirect_to new_partner_api_credential_path, notice: "Partner api credential was successfully destroyed.", status: :see_other
  end

  private

  def redirect_to_edit
    redirect_to edit_partner_api_credential_path(current_user.partner_api_credential)
  end

  def set_partner_api_credential
    @partner_api_credential = current_user.partner_api_credential
  end

  # Only allow a list of trusted parameters through.
  def partner_api_credential_params
    params.require(:partner_api_credential).permit(:access_token, :organization_id)
  end
end
