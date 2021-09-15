class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  has_many :payment_histories, dependent: :delete_all
  has_many :metrics, dependent: :delete_all

  def has_partner_api_credentials?
    partner_api_access_token.present? && partner_api_organization_id.present?
  end
end
