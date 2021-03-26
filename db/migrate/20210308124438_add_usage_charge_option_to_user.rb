class AddUsageChargeOptionToUser < ActiveRecord::Migration
  def change
    add_column :users, :count_usage_charges_as_recurring, :boolean, default: false
  end
end
