class SmiirlIntegration < ApplicationRecord
  METRIC_TYPES = [
    "paying_users_30d",
    "total_revenue_30d"
  ].freeze

  belongs_to :user

  validates :token, presence: true, length: { minimum: 32 }, uniqueness: true
  validates :metric_type, inclusion: { in: METRIC_TYPES }

  before_validation :ensure_token

  def rotate_token!
    update!(token: self.class.generate_unique_token)
  end

  def self.generate_unique_token
    loop do
      token = SecureRandom.hex(16) # 32 chars
      break token unless exists?(token: token)
    end
  end

  private

  def ensure_token
    self.token ||= self.class.generate_unique_token
  end
end

