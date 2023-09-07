class RenamePaymentHistory < ActiveRecord::Migration[7.0]
  def change
    rename_table :payment_histories, :payments
  end
end
