class AddIndexesToModels < ActiveRecord::Migration
  def change
    add_index :metrics, [:user_id, :metric_date]
    add_index :metrics, [:user_id, :charge_type]
    add_index :payment_histories, [:user_id, :payment_date]
    add_index :payment_histories, [:user_id, :charge_type]
  end
end
