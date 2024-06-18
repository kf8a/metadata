class AddAwesomeNestedSetToTreatments < ActiveRecord::Migration[7.1]
  def change
    add_column :treatments, :parent_id, :integer, null: true
    add_column :treatments, :rgt, :integer
    add_column :treatments, :lft, :integer
  end
end
