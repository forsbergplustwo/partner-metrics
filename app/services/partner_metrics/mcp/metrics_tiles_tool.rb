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
            enum: MetricsSerializer::CHARGE_TYPES.keys,
            description: "Metrics page to query. Use overview for /metrics."
          },
          app: {
            type: "string",
            description: "Optional app title filter. Omit for all apps."
          },
          chart: {
            type: "string",
            description: "Optional tile handle to select chart data for. Defaults to the first tile for the charge type."
          },
          date: {
            type: "string",
            format: "date",
            description: "End date for the period. Defaults to the user's newest metric date, or today when no metrics exist."
          },
          period: {
            type: "integer",
            enum: Metric::PERIODS,
            description: "Period length in days. Defaults to 30."
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
        rescue ArgumentError => e
          error_response(e.message)
        end
      end
    end
  end
end
