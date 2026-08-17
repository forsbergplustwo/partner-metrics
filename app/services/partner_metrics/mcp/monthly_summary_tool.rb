module PartnerMetrics
  module Mcp
    class MonthlySummaryTool < ::MCP::Tool
      extend ToolResponse

      tool_name "monthly_summary"
      title "Monthly summary"
      description "Return the monthly summary shown in Partner Metrics for the authenticated user."
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
        title: "Monthly summary"
      )

      class << self
        def call(server_context:, selected_app: nil)
          user = User.find(server_context.fetch(:user_id))
          json_response(MetricsSerializer.monthly_summary(user: user, selected_app: selected_app))
        end
      end
    end
  end
end
