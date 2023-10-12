require "test_helper"

class Imports::DestroyAllControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:regular)
    imports(:completed)
    imports(:failed)
  end

  test "should destroy all imports" do
    assert_not Import.count.zero?

    delete destroy_all_imports_url

    assert_redirected_to imports_url
    assert Import.count.zero?
  end
end
