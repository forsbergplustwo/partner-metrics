require "test_helper"

class Metrics::OnetimeControllerTest < ActionController::TestCase
  test "should get index" do
    sign_in users(:regular)

    get :index
    assert_response :success
    assert_select "h1", "One-Time Revenue"
    assert_select ".main-metric", "$10.00"
  end
end
