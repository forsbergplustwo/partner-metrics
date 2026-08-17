class CreateMcpAccessTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :mcp_access_tokens do |t|
      t.references :user, null: false, foreign_key: true, index: {unique: true}
      t.string :token_digest, null: false
      t.string :token_preview, null: false
      t.datetime :last_used_at

      t.timestamps
    end

    add_index :mcp_access_tokens, :token_digest, unique: true
  end
end
