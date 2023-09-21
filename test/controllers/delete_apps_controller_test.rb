require "test_helper"

class DeleteAppsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    sign_in @user
  end

  test "should get new" do
    get delete_apps_path
    assert_response :success
  end

  test "can create with valid params" do
    post delete_apps_path, params: {delete_apps: {app_title: "test-app-1"}}
    assert_response :redirect
    assert_redirected_to delete_apps_path, notice: "App deleted successfully"
  end

  test "can't create with invalid params" do
    post rename_apps_path, params: {rename_app: {app_title: "unknown"}}
    assert_response :unprocessable_entity
  end
end
