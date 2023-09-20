require "application_system_test_case"

class SummarysTest < ApplicationSystemTestCase
  setup do
    sign_in users(:regular)
  end

  test "should show monthly summary" do
    visit monthly_summarys_path
    find("span.Polaris-Navigation__Text", text: "Monthly summary").click

    assert_selector "h1", text: "Monthly summary"
    assert_selector "td", text: "Jan 2023"
    assert_selector "td", text: "$30"
  end

  test "should show shop summary" do
    visit shop_summarys_path
    find("span.Polaris-Navigation__Text", text: "Shop summary").click

    assert_selector "h1", text: "Shop summary"
    assert_selector "td", text: "test-shop.myshopify.com"
    assert_selector "td", text: "$30"
    assert_selector "td", text: "2023-01-01"
  end
end
