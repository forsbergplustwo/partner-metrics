class AddImportAssociations < ActiveRecord::Migration[7.0]
  def change
    add_reference :payments, :import, index: true
    add_reference :metrics, :import, index: true
  end
end
