require "shopify_partner_api"
require "graphql/client"
require "graphql/client/http"

class PartnerApiCredential < ApplicationRecord
  include ShopifyPartnerAPI

  encrypts :access_token
  encrypts :organization_id

  belongs_to :user

  enum status: {
    draft: "draft",
    valid: "valid",
    invalid: "invalid"
  }, _default: :draft, _suffix: true

  validates :access_token, presence: true
  validates :organization_id, presence: true
  validates :status, presence: true, inclusion: {in: statuses.keys}
  validate :credentials_have_access, on: [:create, :update]

  def context
    {
      access_token: access_token,
      organization_id: organization_id
    }
  end

  private

  def credentials_have_access
    errors.add(:access_token, "is required") if access_token.blank?
    errors.add(:organization_id, "is required") if organization_id.blank?

    if errors.empty?
      response = test_api_credentials
      if response.success?
        puts "Validation success."
        self.status = :valid
        self.status_message = ""
      else
        puts "Validation failed: #{response.error_message}"
        errors.add(:base, "Invalid credentials: #{response.error_message}")
        self.status = :invalid
        self.status_message = response.error_message
      end
    end
  end

  def test_api_credentials
    response = ShopifyPartnerAPI.client.query(
      Graphql::TransactionsQuery,
      variables: {first: 50},
      context: context
    )
    if response.errors.any?
      OpenStruct.new(success?: false, error_message: errors_from_response(response))
    else
      OpenStruct.new(success?: true)
    end
  end

  def errors_from_response(response)
    response.errors.messages.map { |k, v| v }&.to_sentence
  end
end
