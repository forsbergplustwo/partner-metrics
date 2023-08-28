class UserController < ApplicationController
  before_action :authenticate_user!

  def update
    metrics = current_user.metrics.any?
    save_partner_api_credentials
    import_file = user_params["import_file"]
    if import_file.present?
      current_user.update(import_file: import_file, import: "Importing", import_status: 0)
      ImportJob.perform_later(user_id: current_user.id, import_type: :csv)
    elsif metrics.present? && current_user.has_partner_api_credentials?
      flash[:notice] = "Account connection updated! We will import your data automatically, at the end of each day."
    else
      flash[:errors] = "Something went wrong. You either need to add your Partner API credentials, or upload the file for the first import."
    end
  end

  private

  def user_params
    params.require(:user).permit(:import_file, :partner_api_access_token, :partner_api_organization_id, :count_usage_charges_as_recurring)
  end

  def save_partner_api_credentials
    if user_params[:partner_api_access_token].present? && user_params[:partner_api_organization_id].present? && user_params[:count_usage_charges_as_recurring].present?
      current_user.update!(
        partner_api_access_token: user_params[:partner_api_access_token],
        partner_api_organization_id: user_params[:partner_api_organization_id],
        partner_api_errors: "",
        count_usage_charges_as_recurring: user_params[:count_usage_charges_as_recurring]
      )
    end
  end
end
