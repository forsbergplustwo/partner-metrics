require "test_helper"

class SmiirlIntegrationTest < ActiveSupport::TestCase
  test "generates token on create and rotates token" do
    user = users(:regular)
    integration = user.build_smiirl_integration
    assert integration.valid?
    integration.save!
    assert_not_nil integration.token
    assert_equal 32, integration.token.length

    old_token = integration.token
    integration.rotate_token!
    assert_not_equal old_token, integration.token
    assert_equal 32, integration.token.length
  end

  test "metric type validation" do
    user = users(:regular)
    integration = user.build_smiirl_integration(metric_type: "invalid")
    assert_not integration.valid?
    assert_includes integration.errors[:metric_type], "is not included in the list"
  end
end
