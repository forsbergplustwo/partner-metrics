class Imports::GlobesController < ApplicationController
  before_action :authenticate_user!

  def show
    payments = current_user.payment_histories.pluck(:shop_country, :charge_type).last(60)
    globe_data = payments.map { |c| {countryCode: c[0], reverse: c[1] == "refund"} }

    render json: globe_data
  end
end
