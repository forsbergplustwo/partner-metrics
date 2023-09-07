require "application_system_test_case"

class Imports::DestroyAllTest < ApplicationSystemTestCase
  setup do
    sign_in users(:regular)

    @import_one = imports(:completed)
    @import_two = imports(:failed)
  end

  test "destroy all" do
    visit imports_url

    assert_selector "h1", text: "Data imports"

    assert_text "View details", count: 2

    accept_alert do
      click_on "Delete all imports"
    end
    assert_text "All imports deleted"
    assert_text "No imports yet"
  end
end
