require "application_system_test_case"

class HomeTest < ApplicationSystemTestCase
  test "Can visit home page" do
    visit root_url

    assert_text "A free metrics dashboard for Shopify Partners"
  end

  test "can signup from homepage" do
    visit root_url

    click_on "Sign up"
    assert_selector "h1", text: "Sign up"

    assert_selector ".Polaris-Button__Text", text: "Log in"

    fill_in "Email", with: "new@example.com"
    fill_in "Password", with: "password"
    fill_in "Confirm password", with: "password"
    click_on "Sign up"

    assert current_path, metrics_path
  end

  test "can login from homepage" do
    user = users(:regular)

    visit root_url

    click_on "Log in"
    assert_selector "h1", text: "Log in"

    assert_selector ".Polaris-Button__Text", text: "Sign up"
    assert_selector ".Polaris-Button__Text", text: "Forgot password"

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"

    click_on "Log in"

    assert_text "Signed in successfully."
    assert current_path, metrics_path
  end
end
