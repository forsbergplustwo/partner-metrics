class AddPartnerApiAuthToUser < ActiveRecord::Migration
  def change
    add_column :users, :partner_api_access_token, :string
    add_column :users, :partner_api_organization_id, :int
  end
end
