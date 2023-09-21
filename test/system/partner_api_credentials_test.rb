require "application_system_test_case"

class PartnerApiCredentialsTest < ApplicationSystemTestCase
  setup do
    @partner_api_credential = partner_api_credentials(:one)
  end

  test "should create partner api credential" do
    sign_in users(:new)
    PartnerApiCredential.any_instance.expects(:credentials_have_access).returns(true)

    visit root_url
    find("span.Polaris-Navigation__Text", text: "Partner API Credentials").click

    fill_in "Shopify organization ID", with: @partner_api_credential.organization_id
    fill_in "Shopify access token", with: @partner_api_credential.access_token

    click_on "Save"

    assert_text "Partner api credential was successfully created"
  end

  test "should update Partner api credential" do
    sign_in users(:regular)
    PartnerApiCredential.any_instance.expects(:credentials_have_access).returns(true)

    visit root_url
    find("span.Polaris-Navigation__Text", text: "Partner API Credentials").click

    fill_in "Shopify organization ID", with: "54321"
    fill_in "Shopify access token", with: @partner_api_credential.access_token

    click_on "Save"

    assert_text "Partner api credential was successfully updated"
  end

  test "should destroy Partner api credential" do
    sign_in users(:regular)

    visit edit_partner_api_credential_url(@partner_api_credential)

    click_on "Delete"
    within "#destroy-modal" do
      click_on "Delete"
    end
    assert_text "Partner api credential was successfully destroyed"
  end
end
