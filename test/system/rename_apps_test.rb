require "application_system_test_case"

class RenameAppsTest < ApplicationSystemTestCase
  setup do
    sign_in users(:regular)
  end

  test "should be able to rename apps" do
    visit root_url

    click_on "More actions"
    click_on "Rename app"

    assert_selector "h1", text: "Rename app"

    select "test-app-1", from: "rename_app[from]", visible: :all
    select "test-app-2", from: "rename_app[to]", visible: :all

    click_on "Rename app"

    assert_text "App renamed successfully"
  end

  test "should not be able to rename to self" do
    visit root_url

    click_on "More actions"
    click_on "Rename app"

    assert_selector "h1", text: "Rename app"

    select "test-app-1", from: "rename_app[from]", visible: :all
    select "test-app-1", from: "rename_app[to]", visible: :all

    click_on "Rename app"

    assert_text "App rename failed"
  end
end
