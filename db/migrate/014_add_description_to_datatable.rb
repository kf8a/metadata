class AddDescriptionToDatatable < ActiveRecord::Migration[4.2]
  def self.up
    add_column "datatables", "description", :text
  end

  def self.down
    remove_column "datatables", "description"
  end
end
