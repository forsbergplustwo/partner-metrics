require "graphql/client"
require "http_client"

module ShopifyPartnerAPI
  class << self
    delegate :parse, :query, to: :client

    def client
      initialize_client_cache
      cached_client = @_client_cache

      if cached_client != nil
        cached_client
      else
        initialize_client
        @_client_cache
      end
    end

    def initialize_client
      initialize_client_cache
      http = ShopifyPartnerAPI::HTTPClient.new

      # So the schema is not requested every time the client is initialized we store it on disk.
      # If the schema changes, run GraphQL::Client.dump_schema(http, "config/partner-api-schema.json")
      schema = GraphQL::Client.load_schema("config/partner-api-schema.json")
      client = GraphQL::Client.new(schema: schema, execute: http)

      @_client_cache = client
    end

    private

    def initialize_client_cache
      @_client_cache ||= nil
    end
  end
end