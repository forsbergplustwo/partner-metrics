require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup do
    @user = users(:regular)
    sign_in @user
  end

  test "Can visit edit page" do
    visit edit_user_registration_path

    click_on @user.email
    click_on "Edit account"

    assert_selector "h1", text: "Edit account"
    assert_selector "label", text: "Email"
    assert_button "Save", disabled: false
    assert_button "Delete account", disabled: false
  end

  test "can log out" do
    visit root_path

    click_on @user.email
    click_on "Log out"

    assert_text "Not logged in"
    assert_current_path root_path
  end

  test "Can delete account" do
    visit edit_user_registration_path

    click_button "Delete account"

    within "#destroy-modal" do
      click_on "Delete account"
    end

    assert_text "Not logged in"
    assert_current_path root_path
  end
end
