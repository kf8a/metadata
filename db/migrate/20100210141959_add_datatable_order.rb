class AddDatatableOrder < ActiveRecord::Migration
  def self.up
    add_column :datatables, :weight, :integer, :default => 100
    rename_column :treatments, :priority, :weight
    rename_column :themes, :priority, :weight
    rename_column :variates, :position, :weight
    rename_column :studies, :seniority, :weight
    rename_column :scribbles, :order, :weight

  end

  def self.down
    rename_column :scribbles, :weight, :order
    rename_column :studies, :weight, :seniority
    rename_column :variates, :weight, :position
    rename_column :themes, :weight, :priority
    rename_column :treatments, :weight, :priority
    remove_column :datatables, :weight
  end
end
