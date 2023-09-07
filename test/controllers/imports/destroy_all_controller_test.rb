require "test_helper"

class Imports::DestroyAllControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:regular)
    imports(:completed)
    imports(:failed)
  end

  test "should destroy all imports" do
    assert_difference("Import.count", -2) do
      delete destroy_all_imports_url
    end

    assert_redirected_to imports_url
  end
end
