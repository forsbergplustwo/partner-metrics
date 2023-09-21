require "application_system_test_case"

class DeleteAppsTest < ApplicationSystemTestCase
  setup do
    sign_in users(:regular)
  end

  test "should be able to delete app" do
    visit root_url

    click_on "More actions"
    click_on "Delete app"

    assert_selector "h1", text: "Delete app"

    select "test-app-1", from: "delete_apps[app_title]", visible: :all

    click_on "Delete app"

    assert_text "App deleted successfully"
  end
end
