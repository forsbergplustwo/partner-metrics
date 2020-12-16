class AddIndexesOnAppTitle < ActiveRecord::Migration
  def change
    add_index :metrics, [:user_id, :app_title]
    add_index :payment_histories, [:user_id, :app_title]
  end
end
