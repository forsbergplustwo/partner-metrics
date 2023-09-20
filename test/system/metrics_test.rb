require "application_system_test_case"

class MetricsTest < ApplicationSystemTestCase
  setup do
    sign_in users(:regular)
  end

  test "should show overview metrics" do
    visit metrics_url
    find("span.Polaris-Navigation__Text", text: "Metrics").click

    assert_selector "h1", text: "Metrics"
    assert_selector "h2", text: "$30.00"
  end

  test "should show recurring metrics" do
    visit metrics_url
    find("span.Polaris-Navigation__Text", text: "Recurring").click

    assert_selector "h1", text: "Recurring"
    assert_selector "h2", text: "$10.00"
  end

  test "should show onetime metrics" do
    visit metrics_url
    find("span.Polaris-Navigation__Text", text: "One-time").click

    assert_selector "h1", text: "One-time"
    assert_selector "h2", text: "$10.00"
  end

  test "should show affiliate metrics" do
    visit metrics_url
    find("span.Polaris-Navigation__Text", text: "Affiliate").click

    assert_selector "h1", text: "Affiliate"
    assert_selector "h2", text: "$10.00"
  end
end
