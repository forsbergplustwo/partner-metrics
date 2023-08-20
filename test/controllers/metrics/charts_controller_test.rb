# (current_user, params["date"], params["period"].to_i, params["chart_type"], params["app_title"])

require "test_helper"

class Metrics::ChartsControllerTest < ActionController::TestCase
  test "should get show" do
    sign_in users(:regular)

    get :show, params = {
      chart_type: {
        calculation: "sum",
        column: "revenue",
        direction_good: "up",
        display: "currency",
        metric_type: "any",
        title: "Total Revenue",
        type: "total_revenue"
      },
      date: "2023-01-01",
      period: "30"
    }

    assert_response :success
    assert_equal "application/json", response.content_type

    json_response = JSON.parse(response.body)
    assert_equal "30.0", json_response["2023-01-01"]
  end

end
