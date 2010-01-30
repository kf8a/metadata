class AddOnWebToDatatable < ActiveRecord::Migration
  def self.up
    add_column :datatables, :on_web, :boolean, :default => true
  end

  def self.down
    remove_column :datatables, :on_web
  end
end
