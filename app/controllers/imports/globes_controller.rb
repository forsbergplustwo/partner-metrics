class Imports::GlobesController < ApplicationController
  before_action :authenticate_user!

  def show
    payments = current_user.payments.pluck(:shop_country, :charge_type).last(30)
    globe_data = payments.map { |c| {countryCode: c[0], reverse: c[1] == "refund"} }

    render json: globe_data
  end
end