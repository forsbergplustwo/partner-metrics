require "test_helper"

class RenameAppsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get rename_apps_new_url
    assert_response :success
  end

  test "should get create" do
    get rename_apps_create_url
    assert_response :success
  end
end
