class AddImportStatusToUser < ActiveRecord::Migration
  def change
    add_column :users, :import, :string
    add_column :users, :import_status, :int, default: 0
  end
end
