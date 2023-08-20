require "test_helper"

class MetricsControllerTest < ActionController::TestCase
  test "should get index and show metrics" do
    sign_in users(:regular)

    get :index

    assert_response :success
    assert_select "h1", "Overview"
    assert_select ".main-metric", "$30.00"
  end

  test "logged out user should get redirected" do
    get :index

    assert_redirected_to new_user_session_path
  end

  test "new user should get index and see no metrics" do
    sign_in users(:new)

    get :index

    assert_response :success
    assert_select "h1", "Overview"
    assert_select "h2", "Welcome!"
    assert_select ".main-metric", {count: 0}
  end
end
