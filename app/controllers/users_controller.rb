class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update(user_params)
      redirect_to request.referrer, status: :see_other
    else
      redirect_to request.referrer, alert: "Error saving user!", status: :see_other
    end
  end

  private

  def user_params
    params.require(:user).permit(:show_forecasts)
  end
end
