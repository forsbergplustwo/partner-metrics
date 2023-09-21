class CreateImports < ActiveRecord::Migration[7.0]
  def change
    create_table :imports do |t|
      t.string :source, null: false
      t.string :status, null: false
      t.integer :progress, null: false, default: 0
      t.references :user, null: false, foreign_key: true
      t.string :timestamps
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
