class CreateSmiirlIntegrations < ActiveRecord::Migration[7.0]
  def change
    create_table :smiirl_integrations do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.boolean :enabled, null: false, default: false
      t.string :metric_type, null: false, default: "total_revenue_30d"
      t.string :token, null: false, limit: 64

      t.timestamps
    end

    add_index :smiirl_integrations, :token, unique: true
  end
end
