require "test_helper"

class SmiirlIntegrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    sign_in @user
  end

  test "show renders" do
    get smiirl_integration_url
    assert_response :success
  end

  test "update toggles enabled and metric_type" do
    put smiirl_integration_url, params: {smiirl_integration: {enabled: true, metric_type: "total_revenue_30d"}}
    assert_redirected_to smiirl_integration_url
    @user.reload
    assert @user.smiirl_integration.enabled?
    assert_equal "total_revenue_30d", @user.smiirl_integration.metric_type
  end

  test "rotate token changes token" do
    @user.create_smiirl_integration!
    old = @user.smiirl_integration.token
    post rotate_token_smiirl_integration_url
    assert_redirected_to smiirl_integration_url
    @user.reload
    assert_not_equal old, @user.smiirl_integration.token
  end
end
