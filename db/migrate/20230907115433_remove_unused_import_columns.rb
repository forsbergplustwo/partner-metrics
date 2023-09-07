class RemoveUnusedImportColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :imports, :started_at, :datetime
    remove_column :imports, :ended_at, :datetime
    remove_column :imports, :progress, :integer
    remove_column :imports, :timestamps, :string
  end
end
