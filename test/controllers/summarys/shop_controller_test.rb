require 'test_helper'

class ShopControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
    @selected_app = apps(:one)
    @summary = Summary::Shop.new(user: @user, selected_app: @selected_app).summarize(page: 1, per_page: 1)
    sign_in @user
  end

  test "index pagination" do
    get :index, params: {selected_app: @selected_app.id, page: 1 }
    assert_response :success
    assert_equal @summary, assigns(:summaries)
  end
end
