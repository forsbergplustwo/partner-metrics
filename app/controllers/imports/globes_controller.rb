class Imports::GlobesController < ApplicationController
  before_action :authenticate_user!

  def show
    @import = current_user.imports.find(params[:import_id])
    @globe_data = globe_data

    respond_to do |format|
      format.json { render json: @globe_data }
      format.html { render :show }
    end
  end

  private

  def globe_data
    @import.payments
      .where.not(shop_country: nil)
      .pluck(:shop_country, :charge_type)
      .map { |country, charge_type| {countryCode: country, reverse: charge_type == "refund"} }
  end
end
