class AddConnectionErrorToUser < ActiveRecord::Migration
  def change
    add_column :users, :partner_api_errors, :text
  end
end
