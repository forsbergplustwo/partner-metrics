class Imports::DestroyAllController < ApplicationController
  before_action :authenticate_user!

  def destroy
    current_user.imports.destroy_all
    redirect_to imports_url, notice: "All imports deleted", status: :see_other
  end
end
