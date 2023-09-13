class CreatePartnerApiCredentials < ActiveRecord::Migration[7.0]
  def change
    create_table :partner_api_credentials do |t|
      t.references :user, null: false, foreign_key: true, index: {unique: true}
      t.string :access_token, null: false, length: 510
      t.string :organization_id, null: false, length: 510
      t.string :status, null: false
      t.text :status_message

      t.timestamps
    end
  end
end
