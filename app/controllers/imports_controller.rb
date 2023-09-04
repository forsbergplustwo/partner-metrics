class ImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_import, only: %i[show update destroy]

  # GET /imports
  def index
    @imports = Import.all
  end

  # GET /imports/1
  def show
  end

  # GET /imports/new
  def new
    @import = current_user.imports.new(source: Import::IMPORT_FILE_SOURCE)
  end

  # POST /imports
  def create
    @import = current_user.imports.new(source: Import::IMPORT_FILE_SOURCE, **import_params)

    if @import.save!
      redirect_to @import, notice: "Import was successfully created."
    else
      flash.now[:alert] = "Import failed to create."
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /imports/1
  def destroy
    @import.destroy
    redirect_to imports_url, notice: "Import was successfully destroyed.", status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_import
    @import = current_user.imports.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def import_params
    params.require(:import).permit(:import_type, :payouts_file)
  end
end
