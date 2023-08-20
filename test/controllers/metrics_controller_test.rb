require "test_helper"

class MetricsControllerTest < ActionController::TestCase
  test "should get index" do
    sign_in users(:regular)

    get :index
    assert_response :success
  end
end
