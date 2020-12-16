class AddIndexToPaymentHistory < ActiveRecord::Migration
  def change
    add_index(:payment_histories, [:user_id, :payment_date, :charge_type, :app_title, :shop], name: "payment_histories_full_index")
  end
end
