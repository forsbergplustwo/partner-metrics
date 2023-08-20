require "test_helper"

class Metrics::RecurringControllerTest < ActionController::TestCase
  test "should get index" do
    sign_in users(:regular)

    get :index
    assert_response :success
    assert_select "h1", "Recurring Revenue"
    assert_select ".main-metric", "$10.00"
  end
end
