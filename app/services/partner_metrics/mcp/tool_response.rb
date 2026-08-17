module PartnerMetrics
  module Mcp
    module ToolResponse
      def json_response(payload)
        ::MCP::Tool::Response.new(
          [{type: "text", text: JSON.pretty_generate(payload)}],
          structured_content: payload
        )
      end

    end
  end
end
