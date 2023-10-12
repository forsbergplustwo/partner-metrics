module ShopifyPartnerAPI
  class HTTPClient < GraphQL::Client::HTTP
    SHOPIFY_PARTNER_API_VERSION = "2023-10"

    def initialize
      super("https://partners.shopify.com/")
    end

    def headers(context)
      {
        "X-Shopify-Access-Token": context.fetch(:access_token)
      }
    end

    def execute(document:, operation_name: nil, variables: {}, context: {})
      @uri = URI.parse("https://partners.shopify.com/#{context.fetch(:organization_id)}/api/#{SHOPIFY_PARTNER_API_VERSION}/graphql.json")

      super(document: document, operation_name: operation_name, variables: variables, context: context)
    end
  end
end
