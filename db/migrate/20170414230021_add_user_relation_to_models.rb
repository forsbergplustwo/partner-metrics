class AddUserRelationToModels < ActiveRecord::Migration
  def change
    add_reference :metrics, :user
    add_reference :payment_histories, :user
  end
end
