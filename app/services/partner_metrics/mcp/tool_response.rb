module PartnerMetrics
  module Mcp
    module ToolResponse
      def json_response(payload)
        ::MCP::Tool::Response.new(
          [{type: "text", text: JSON.pretty_generate(payload)}],
          structured_content: payload
        )
      end

      def error_response(message)
        ::MCP::Tool::Response.new(
          [{type: "text", text: message}],
          error: true
        )
      end
    end
  end
end
