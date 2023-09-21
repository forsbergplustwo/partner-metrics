class AddIsYearlyRevenue < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :is_yearly_revenue, :boolean, default: false
    add_column :metrics, :is_yearly_revenue, :boolean, default: false
  end
end
