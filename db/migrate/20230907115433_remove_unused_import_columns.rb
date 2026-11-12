# frozen_string_literal: true

class RemoveUnusedImportColumns < ActiveRecord::Migration[7.0]
  def change
    change_table(:imports, bulk: true) do |t|
      t.remove(:started_at, type: :datetime)
      t.remove(:ended_at, type: :datetime)
      t.remove(:progress, type: :integer)
      t.remove(:timestamps, type: :string)
    end
  end
end
