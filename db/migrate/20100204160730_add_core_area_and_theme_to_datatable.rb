class AddCoreAreaAndThemeToDatatable < ActiveRecord::Migration[4.2]
  def self.up
    add_column :datatables, :theme_id, :integer
    add_column :datatables, :core_area_id, :integer
  end

  def self.down
    remove_column :datatables, :core_area_id
    remove_column :datatables, :theme_id
  end
end
