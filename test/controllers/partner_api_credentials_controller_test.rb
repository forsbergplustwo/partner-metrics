require "test_helper"

class PartnerApiCredentialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @partner_api_credential = partner_api_credentials(:one)
  end

  test "should get new when no credential exists" do
    sign_in users(:new)
    get new_partner_api_credential_url
    assert_response :success
  end

  test "should get edit when credential exists" do
    sign_in users(:regular)
    get new_partner_api_credential_url
    assert_redirected_to edit_partner_api_credential_url(@partner_api_credential)
  end

  test "should create partner_api_credential" do
    sign_in users(:new)

    PartnerApiCredential.any_instance.expects(:credentials_have_access).returns(true)

    assert_difference("PartnerApiCredential.count") do
      post partner_api_credentials_url, params: { partner_api_credential: { access_token: @partner_api_credential.access_token, organization_id: @partner_api_credential.organization_id } }
    end

    assert_redirected_to edit_partner_api_credential_url(PartnerApiCredential.last)
  end

  test "should get edit" do
    sign_in users(:regular)
    get edit_partner_api_credential_url(@partner_api_credential)
    assert_response :success
  end

  test "should update partner_api_credential" do
    sign_in users(:regular)

    PartnerApiCredential.any_instance.expects(:credentials_have_access).returns(true)

    patch partner_api_credential_url(@partner_api_credential),
      params: {
        partner_api_credential: {
          access_token: @partner_api_credential.access_token,
          organization_id: @partner_api_credential.organization_id,
          user_attributes: {
            count_usage_charges_as_recurring: "1"
          }
        }
      }
    assert_redirected_to edit_partner_api_credential_url(@partner_api_credential)
  end

  test "should destroy partner_api_credential" do
    sign_in users(:regular)

    assert_difference("PartnerApiCredential.count", -1) do
      delete partner_api_credential_url(@partner_api_credential)
    end

    assert_redirected_to new_partner_api_credential_url
  end
end
