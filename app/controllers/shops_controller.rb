class ShopsController < ApplicationController
  def index
    # Assuming Kaminari for pagination. Replace with will_paginate equivalent if necessary.
    @shops = Shop.all.page(params[:page]).per(100)
  end
end
