module PartnerMetrics
  module Mcp
    class MetricsTilesTool < ::MCP::Tool
      extend ToolResponse

      tool_name "metrics_tiles"
      title "Metrics tiles"
      description "Return the same metrics tiles shown on the Partner Metrics metrics page for the authenticated user."
      input_schema(
        properties: {
          charge_type: {
            type: "string",
            enum: Metric::DISPLAYABLE_TYPES.map(&:to_s),
            description: "Optional metrics page charge type. Omit for /metrics."
          },
          app: {
            type: "string",
            description: "Optional app title filter. Omit for all apps."
          },
          chart: {
            type: "string",
            description: "Optional tile handle to select chart data for."
          },
          date: {
            type: "string",
            format: "date",
            description: "Optional end date for the period."
          },
          period: {
            type: "integer",
            enum: Metric::PERIODS,
            description: "Optional period length in days."
          }
        }
      )
      annotations(
        read_only_hint: true,
        destructive_hint: false,
        idempotent_hint: true,
        open_world_hint: false,
        title: "Metrics tiles"
      )

      class << self
        def call(server_context:, **args)
          user = User.find(server_context.fetch(:user_id))
          json_response(MetricsSerializer.tiles(user: user, params: args))
        end
      end
    end
  end
end
