require "test_helper"

class PartnerApiCredentialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @partner_api_credential = partner_api_credentials(:one)
  end

  test "should get index" do
    get partner_api_credentials_url
    assert_response :success
  end

  test "should get new" do
    get new_partner_api_credential_url
    assert_response :success
  end

  test "should create partner_api_credential" do
    assert_difference("PartnerApiCredential.count") do
      post partner_api_credentials_url, params: { partner_api_credential: { access_token: @partner_api_credential.access_token, organization_id: @partner_api_credential.organization_id, status: @partner_api_credential.status, status_message: @partner_api_credential.status_message, user_id: @partner_api_credential.user_id } }
    end

    assert_redirected_to partner_api_credential_url(PartnerApiCredential.last)
  end

  test "should show partner_api_credential" do
    get partner_api_credential_url(@partner_api_credential)
    assert_response :success
  end

  test "should get edit" do
    get edit_partner_api_credential_url(@partner_api_credential)
    assert_response :success
  end

  test "should update partner_api_credential" do
    patch partner_api_credential_url(@partner_api_credential), params: { partner_api_credential: { access_token: @partner_api_credential.access_token, organization_id: @partner_api_credential.organization_id, status: @partner_api_credential.status, status_message: @partner_api_credential.status_message, user_id: @partner_api_credential.user_id } }
    assert_redirected_to partner_api_credential_url(@partner_api_credential)
  end

  test "should destroy partner_api_credential" do
    assert_difference("PartnerApiCredential.count", -1) do
      delete partner_api_credential_url(@partner_api_credential)
    end

    assert_redirected_to partner_api_credentials_url
  end
end
