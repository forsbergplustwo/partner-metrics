require "test_helper"

class PublicSmiirlControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    @integration = @user.create_smiirl_integration!(enabled: true, metric_type: "paying_users_30d")
    # Ensure payments exist in last 30 days
    Payment.create!(user: @user, import: imports(:completed), payment_date: Time.zone.today, charge_type: "recurring_revenue", app_title: "x", shop: "a", revenue: 10)
  end

  test "returns count json when enabled" do
    get public_smiirl_url(token: @integration.token)
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal({"count" => 1}, json)
  end

  test "returns 404 when disabled" do
    @integration.update!(enabled: false)
    get public_smiirl_url(token: @integration.token)
    assert_response :not_found
  end

  test "returns 404 for unknown token" do
    get public_smiirl_url(token: "unknown")
    assert_response :not_found
  end
end
