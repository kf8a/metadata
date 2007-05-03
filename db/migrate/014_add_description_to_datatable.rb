class AddDescriptionToDatatable < ActiveRecord::Migration
  def self.up
    add_column "datatables", "description", :text
  end

  def self.down
    remove_column "datatables", "description"
  end
end
