require "test_helper"

class McpAccessTokensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    sign_in @user
  end

  test "edit renders without a token" do
    get edit_mcp_access_token_url

    assert_response :success
  end

  test "create stores only a digest and shows raw token once" do
    post mcp_access_token_url
    assert_redirected_to edit_mcp_access_token_url

    plain_text_token = flash[:mcp_access_token]
    assert plain_text_token.present?

    @user.reload
    assert @user.mcp_access_token.present?
    assert_not_equal plain_text_token, @user.mcp_access_token.token_digest
    assert_equal McpAccessToken.digest_token(plain_text_token), @user.mcp_access_token.token_digest
  end

  test "destroy revokes the token" do
    McpAccessToken.issue_for!(@user)

    delete mcp_access_token_url

    assert_redirected_to edit_mcp_access_token_url
    assert_nil @user.reload.mcp_access_token
  end
end
