class AddShowForecastsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :show_forecasts, :boolean, default: false, null: false
  end
end
