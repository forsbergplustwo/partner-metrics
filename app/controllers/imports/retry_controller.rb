class Imports::RetryController < ApplicationController
  before_action :authenticate_user!

  def create
    @import = current_user.imports.find(params[:import_id])
    if @import.retriable? && @import.retry
      redirect_to @import, notice: "Import being retried."
    else
      redirect_to @import, alert: "Import failed to retry."
    end
  end
end
