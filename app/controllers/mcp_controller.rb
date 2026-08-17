class McpController < ActionController::API
  MCP_ALLOWED_HOSTS = [
    "partnermetrics.io",
    "www.partnermetrics.io",
    "localhost",
    "127.0.0.1",
    "::1",
    "www.example.com"
  ].freeze

  MCP_ALLOWED_ORIGINS = [
    "https://partnermetrics.io",
    "https://www.partnermetrics.io",
    "http://localhost",
    "http://127.0.0.1",
    "http://www.example.com"
  ].freeze

  before_action :authenticate_mcp_user!

  def handle
    status, headers, body = transport.handle_request(request)

    headers.each { |key, value| response.set_header(key, value) }
    self.status = status
    self.response_body = body
  end

  private

  attr_reader :current_mcp_user

  def authenticate_mcp_user!
    @current_mcp_user = McpAccessToken.authenticate(bearer_token)
    return if @current_mcp_user.present?

    response.set_header("WWW-Authenticate", %(Bearer realm="Partner Metrics MCP"))
    render json: {error: "unauthorized"}, status: :unauthorized
  end

  def bearer_token
    authorization = request.headers["Authorization"].to_s
    authorization[/\ABearer\s+(.+)\z/i, 1]
  end

  def transport
    ::MCP::Server::Transports::StreamableHTTPTransport.new(
      server,
      stateless: true,
      enable_json_response: true,
      allowed_hosts: allowed_hosts,
      allowed_origins: allowed_origins
    )
  end

  def server
    ::MCP::Server.new(
      name: "partner_metrics",
      title: "Partner Metrics",
      version: "1.0.0",
      website_url: "https://partnermetrics.io",
      instructions: "Use these read-only tools to answer questions about the authenticated user's Partner Metrics data.",
      tools: [
        PartnerMetrics::Mcp::MetricsTilesTool,
        PartnerMetrics::Mcp::MonthlySummaryTool,
        PartnerMetrics::Mcp::ShopSummaryTool
      ],
      server_context: {user_id: current_mcp_user.id}
    )
  end

  def allowed_hosts
    Rails.configuration.x.mcp_allowed_hosts + MCP_ALLOWED_HOSTS
  end

  def allowed_origins
    Rails.configuration.x.mcp_allowed_origins + MCP_ALLOWED_ORIGINS
  end
end
