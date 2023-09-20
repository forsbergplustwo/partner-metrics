require "application_system_test_case"

class ImportsTest < ApplicationSystemTestCase
  setup do
    sign_in users(:regular)
    @import = imports(:completed)
  end

  test "visiting the index with an import" do
    visit imports_url
    find("span.Polaris-Navigation__Text", text: "Data imports").click

    assert_selector "h1", text: "Data imports"

    assert_text "View details"
  end

  test "visiting the index with no import" do
    Import.destroy_all

    visit imports_url
    assert_selector "h1", text: "Data imports"

    assert_text "No imports yet"
  end

  test "should create import" do
    visit imports_url
    click_on "New import"

    assert_text "Import"
    assert_text "Draft"
    assert_text "Add file"

    attach_to_import("payouts-recurring.csv")

    assert_button "Save", disabled: false
    click_on "Save"

    assert_text "Import successfully created."
    assert_text "Import details"
  end

  test "should destroy Import" do
    visit import_url(@import)

    click_on "Delete import"
    within "#destroy-modal" do
      click_on "Delete import"
    end

    assert_text "Import successfully destroyed."

    assert_selector "h1", text: "Data imports"
  end
end
