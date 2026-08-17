class McpAccessTokensController < ApplicationController
  before_action :authenticate_user!

  def edit
    @mcp_access_token = current_user.mcp_access_token
    @plain_text_token = flash[:mcp_access_token]
  end

  def create
    _access_token, plain_text_token = McpAccessToken.issue_for!(current_user)
    flash[:mcp_access_token] = plain_text_token
    redirect_to edit_mcp_access_token_path, notice: "MCP access token created. Copy it now; it will not be shown again."
  end

  def destroy
    current_user.mcp_access_token&.destroy!
    redirect_to edit_mcp_access_token_path, notice: "MCP access token revoked."
  end
end
