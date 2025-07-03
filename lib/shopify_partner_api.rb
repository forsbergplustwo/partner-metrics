require "graphql/client"
require "graphql/client/http"
require "http_client"

module ShopifyPartnerAPI
  class << self
    delegate :parse, :query, to: :client

    def client
      Thread.current[:_shopify_client_cache] ||= initialize_client
    end

    def initialize_client
      http = ShopifyPartnerAPI::HTTPClient.new

      # So the schema is not requested every time the client is initialized we store it on disk.
      # If the schema (or Shopify Partner API version) changes, run:
      # GraphQL::Client.dump_schema(
      #   http,
      #   "config/partner-api-schema.json",
      #   context: {organization_id: "xxxx", access_token: "xxxx"}
      # )
      #
      # to update the schema in the file.
      schema = GraphQL::Client.load_schema("config/partner-api-schema.json")
      GraphQL::Client.new(schema: schema, execute: http)
    end
  end
end
