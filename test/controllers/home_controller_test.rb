require "test_helper"

class HomeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_select "h1", "A free metrics dashboard forShopify Partners"
  end

  test "logged in user should get redirected" do
    sign_in users(:regular)

    get :index
    assert_redirected_to metrics_path
  end

  test "should get app_store_analytics" do
    sign_in users(:regular)

    get :app_store_analytics
    assert_response :success
  end
end
