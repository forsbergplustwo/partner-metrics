module PartnerMetrics
  module Mcp
    class ShopSummaryTool < ::MCP::Tool
      extend ToolResponse

      tool_name "shop_summary"
      title "Shop summary"
      description "Return the top shop summary shown in Partner Metrics for the authenticated user."
      input_schema(
        properties: {
          selected_app: {
            type: "string",
            description: "Optional app title filter. Omit for all apps."
          }
        }
      )
      annotations(
        read_only_hint: true,
        destructive_hint: false,
        idempotent_hint: true,
        open_world_hint: false,
        title: "Shop summary"
      )

      class << self
        def call(server_context:, selected_app: nil)
          user = User.find(server_context.fetch(:user_id))
          json_response(MetricsSerializer.shop_summary(user: user, selected_app: selected_app.presence))
        end
      end
    end
  end
end
