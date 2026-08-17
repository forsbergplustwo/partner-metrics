class McpAccessToken < ApplicationRecord
  TOKEN_PREFIX = "pmcp_".freeze

  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true
  validates :token_preview, presence: true

  class << self
    def issue_for!(user)
      token = generate_unique_token
      access_token = user.mcp_access_token || user.build_mcp_access_token
      access_token.assign_token(token)
      access_token.save!
      [access_token, token]
    end

    def authenticate(token)
      return nil if token.blank?

      digest = digest_token(token)
      access_token = find_by(token_digest: digest)
      return nil if access_token.blank?

      access_token.touch(:last_used_at)
      access_token.user
    end

    def digest_token(token)
      Digest::SHA256.hexdigest(token)
    end

    private

    def generate_unique_token
      loop do
        token = "#{TOKEN_PREFIX}#{SecureRandom.urlsafe_base64(32)}"
        break token unless exists?(token_digest: digest_token(token))
      end
    end
  end

  def assign_token(token)
    self.token_digest = self.class.digest_token(token)
    self.token_preview = "#{token.first(10)}...#{token.last(4)}"
  end
end
