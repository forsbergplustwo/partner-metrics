class ImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_import, only: %i[show update destroy]

  def index
    @imports = current_user.imports.all.order(created_at: :desc)
  end

  def show
  end

  def new
    redirect_if_import_in_progress
    @import = current_user.imports.new(source: Import.sources[:csv_file])
  end

  def create
    @import = current_user.imports.new(source: Import.sources[:csv_file], **import_params)
    @import.user.count_usage_charges_as_recurring = import_params.dig(:user_attributes, :count_usage_charges_as_recurring)
    if @import.save
      redirect_to @import, notice: "Import successfully created."
    else
      flash.now[:alert] = "Import failed to create."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @import.destroy
    redirect_to imports_url, notice: "Import successfully destroyed.", status: :see_other
  end

  private

  def set_import
    @import = current_user.imports.find(params[:id])
  end

  def import_params
    params.require(:import).permit(
      :import_type,
      :payouts_file,
      user_attributes: [:count_usage_charges_as_recurring]
    )
  end

  def redirect_if_import_in_progress
    if current_user.imports.in_progress.any?
      redirect_to imports_path, alert: "An import is already in progress."
    end
  end
end
