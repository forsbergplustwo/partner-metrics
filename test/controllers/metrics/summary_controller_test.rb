require "test_helper"

class Metrics::SummaryControllerTest < ActionController::TestCase
  test "should get index" do
    sign_in users(:regular)

    get :index
    assert_response :success
    assert_select "h1", "Monthly summary"
    assert_select "b", "Select an app"
  end

  test "should get index with app and show summary" do
    sign_in users(:regular)

    get :index, app_title: "test-app"
    assert_response :success

    assert_select "h3", "Financial History (last 36 months)"
  end
end
