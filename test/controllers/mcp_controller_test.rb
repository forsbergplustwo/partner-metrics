require "test_helper"

class McpControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    @access_token, @plain_text_token = McpAccessToken.issue_for!(@user)
  end

  test "unauthenticated requests return 401" do
    post mcp_url, params: json_rpc("tools/list").to_json, headers: mcp_headers(token: nil)

    assert_response :unauthorized
    assert_match "Bearer", response.headers["WWW-Authenticate"]
  end

  test "wrong token requests return 401" do
    post mcp_url, params: json_rpc("tools/list").to_json, headers: mcp_headers(token: "wrong")

    assert_response :unauthorized
  end

  test "valid token can initialize, list tools, and fetch metrics" do
    initialize_mcp!

    post_mcp!("tools/list")
    tool_names = json_response.dig("result", "tools").map { |tool| tool.fetch("name") }
    assert_includes tool_names, "metrics_tiles"
    assert_includes tool_names, "monthly_summary"
    assert_includes tool_names, "shop_summary"

    result = call_tool!("metrics_tiles", {})
    assert_equal "overview", result.dig("structuredContent", "filters", "charge_type")
    assert_equal "30.0", result.dig("structuredContent", "tiles").find { |tile| tile["handle"] == "total_revenue" }.fetch("current_value")
  end

  test "metrics data is scoped to the bearer token user" do
    other_user = users(:new)
    Metric.create!(
      user: other_user,
      import: imports(:completed),
      metric_date: @user.newest_metric_date,
      charge_type: "recurring_revenue",
      app_title: "other-user-app",
      revenue: 999,
      number_of_charges: 1,
      number_of_shops: 1
    )

    result = call_tool!("metrics_tiles", {})
    total_revenue = result.dig("structuredContent", "tiles").find { |tile| tile["handle"] == "total_revenue" }

    assert_equal "30.0", total_revenue.fetch("current_value")
    assert_not_includes result.dig("structuredContent", "app_titles"), "other-user-app"
  end

  test "metrics defaults match TilesFilter" do
    result = call_tool!("metrics_tiles", {})
    content = result.fetch("structuredContent")
    filter = Metric::TilesFilter.new(user: @user, params: {})

    assert_equal filter.date.iso8601, content.dig("filters", "date")
    assert_equal filter.period, content.dig("filters", "period")
    assert_equal "overview", content.dig("filters", "charge_type")
    assert_equal filter.selected_tile.current_value.to_s("F"), content.dig("selected_tile", "current_value")
    assert_equal filter.selected_tile.previous_value.to_s("F"), content.dig("selected_tile", "previous_value")
  end

  test "each UI charge type exposes the same tile set" do
    {
      "overview" => Metric::TilesConfig::OVERVIEW_TILES,
      "recurring_revenue" => Metric::TilesConfig::RECURRING_TILES,
      "onetime_revenue" => Metric::TilesConfig::ONETIME_TILES,
      "affiliate_revenue" => Metric::TilesConfig::AFFILIATE_TILES
    }.each do |charge_type, config|
      result = call_tool!("metrics_tiles", {charge_type: charge_type})
      handles = result.dig("structuredContent", "tiles").map { |tile| tile.fetch("handle") }

      assert_equal config.map { |tile| tile.fetch(:handle).to_s }, handles
    end
  end

  test "app date and period filters match TilesFilter values" do
    Metric.create!(
      user: @user,
      import: imports(:completed),
      metric_date: Date.new(2023, 1, 2),
      charge_type: "recurring_revenue",
      app_title: "filtered-app",
      revenue: 42,
      number_of_charges: 1,
      number_of_shops: 1
    )
    Metric.create!(
      user: @user,
      import: imports(:completed),
      metric_date: Date.new(2023, 1, 2),
      charge_type: "recurring_revenue",
      app_title: "ignored-app",
      revenue: 100,
      number_of_charges: 1,
      number_of_shops: 1
    )

    arguments = {app: "filtered-app", date: "2023-01-02", period: 1, charge_type: "recurring_revenue"}
    result = call_tool!("metrics_tiles", arguments)
    filter = Metric::TilesFilter.new(user: @user, params: arguments)
    recurring_tile = filter.tiles.find { |tile| tile.handle == :recurring_revenue }
    mcp_recurring_tile = result.dig("structuredContent", "tiles").find { |tile| tile["handle"] == "recurring_revenue" }

    assert_equal recurring_tile.current_value.to_s("F"), mcp_recurring_tile.fetch("current_value")
    assert_equal "42.0", mcp_recurring_tile.fetch("current_value")
  end

  test "summary tools use existing summary objects" do
    monthly = call_tool!("monthly_summary", {selected_app: "test-app"})
    expected_monthly = Summary::Monthly.new(user: @user, selected_app: "test-app").summarize

    assert_equal expected_monthly.keys.map { |month| month.to_date.iso8601 }, monthly.dig("structuredContent", "months").map { |month| month.fetch("month") }

    shop = call_tool!("shop_summary", {selected_app: "test-app"})
    expected_shop = Summary::Shop.new(user: @user, selected_app: "test-app").summarize

    assert_equal expected_shop.keys, shop.dig("structuredContent", "shops").map { |summary| summary.fetch("shop") }
  end

  test "rotating and revoking token invalidates old tokens" do
    sign_in @user

    post mcp_access_token_url
    old_token = flash[:mcp_access_token]
    assert old_token.present?

    post mcp_access_token_url
    new_token = flash[:mcp_access_token]
    assert new_token.present?
    assert_not_equal old_token, new_token

    post mcp_url, params: json_rpc("tools/list").to_json, headers: mcp_headers(token: old_token)
    assert_response :unauthorized

    post_mcp!("tools/list", token: new_token)

    delete mcp_access_token_url
    post mcp_url, params: json_rpc("tools/list").to_json, headers: mcp_headers(token: new_token)
    assert_response :unauthorized
  end

  private

  def initialize_mcp!
    post_mcp!(
      "initialize",
      params: {
        protocolVersion: "2025-06-18",
        capabilities: {},
        clientInfo: {
          name: "partner-metrics-test",
          version: "1.0.0"
        }
      }
    )
  end

  def call_tool!(name, arguments)
    post_mcp!("tools/call", params: {name: name, arguments: arguments})
    json_response.fetch("result")
  end

  def post_mcp!(method, params: {}, token: @plain_text_token)
    post mcp_url, params: json_rpc(method, params: params).to_json, headers: mcp_headers(token: token)
    assert_response :success
  end

  def json_rpc(method, params: {})
    {
      jsonrpc: "2.0",
      id: SecureRandom.uuid,
      method: method,
      params: params
    }
  end

  def json_response
    JSON.parse(response.body)
  end

  def mcp_headers(token:)
    headers = {
      "CONTENT_TYPE" => "application/json",
      "ACCEPT" => "application/json"
    }
    headers["Authorization"] = "Bearer #{token}" if token.present?
    headers
  end
end
