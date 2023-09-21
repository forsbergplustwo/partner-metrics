require "test_helper"

class RenameAppsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    sign_in @user
  end

  test "should get new" do
    get rename_apps_path
    assert_response :success
  end

  test "can create with valid params" do
    post rename_apps_path, params: {rename_app: {from: "App1", to: "App2"}}
    assert_response :redirect
    assert_redirected_to rename_apps_path, notice: "App renamed successfully"
  end

  test "can't create with invalid params" do
    post rename_apps_path, params: {rename_app: {from: "App1", to: ""}}
    assert_response :unprocessable_entity
  end
end
