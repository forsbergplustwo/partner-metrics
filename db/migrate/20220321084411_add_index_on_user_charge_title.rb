class AddIndexOnUserChargeTitle < ActiveRecord::Migration
  def change
    add_index :payment_histories, [:user_id, :charge_type, :app_title], name: "payment_histories_user_charge_title_index"
  end
end
