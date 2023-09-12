require "application_system_test_case"

class PartnerApiCredentialsTest < ApplicationSystemTestCase
  setup do
    @partner_api_credential = partner_api_credentials(:one)
  end

  test "visiting the index" do
    visit partner_api_credentials_url
    assert_selector "h1", text: "Partner api credentials"
  end

  test "should create partner api credential" do
    visit partner_api_credentials_url
    click_on "New partner api credential"

    fill_in "Access token", with: @partner_api_credential.access_token
    fill_in "Organization", with: @partner_api_credential.organization_id
    fill_in "Status", with: @partner_api_credential.status
    fill_in "Status message", with: @partner_api_credential.status_message
    fill_in "User", with: @partner_api_credential.user_id
    click_on "Create Partner api credential"

    assert_text "Partner api credential was successfully created"
    click_on "Back"
  end

  test "should update Partner api credential" do
    visit partner_api_credential_url(@partner_api_credential)
    click_on "Edit this partner api credential", match: :first

    fill_in "Access token", with: @partner_api_credential.access_token
    fill_in "Organization", with: @partner_api_credential.organization_id
    fill_in "Status", with: @partner_api_credential.status
    fill_in "Status message", with: @partner_api_credential.status_message
    fill_in "User", with: @partner_api_credential.user_id
    click_on "Update Partner api credential"

    assert_text "Partner api credential was successfully updated"
    click_on "Back"
  end

  test "should destroy Partner api credential" do
    visit partner_api_credential_url(@partner_api_credential)
    click_on "Destroy this partner api credential", match: :first

    assert_text "Partner api credential was successfully destroyed"
  end
end
