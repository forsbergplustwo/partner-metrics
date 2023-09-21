class Imports::GlobesController < ApplicationController
  before_action :authenticate_user!

  def show
    @import = current_user.imports.find(params[:import_id])

    render json: globe_data
  end

  private

  def globe_data
    payments = @import.payments.pluck(:shop_country, :charge_type).last(72)
    globe_data = []
    payments.each do |c|
      globe_data << {countryCode: c[0], reverse: c[1] == "refund"}
    end
    globe_data
  end
end
