module PartnerMetrics
  module Mcp
    class MetricOptionsTool < ::MCP::Tool
      extend ToolResponse

      tool_name "metric_options"
      title "Metric filter options"
      description "Return available Partner Metrics MCP filter options for the authenticated user."
      input_schema(properties: {})
      annotations(
        read_only_hint: true,
        destructive_hint: false,
        idempotent_hint: true,
        open_world_hint: false,
        title: "Metric filter options"
      )

      class << self
        def call(server_context:)
          user = User.find(server_context.fetch(:user_id))
          json_response(MetricsSerializer.options(user: user))
        end
      end
    end
  end
end
