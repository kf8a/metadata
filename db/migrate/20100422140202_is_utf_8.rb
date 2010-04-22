class IsUtf8 < ActiveRecord::Migration
  def self.up
    add_column :datatables, :is_utf_8, :boolean, :default=>false
  end

  def self.down
    remove_column :datatables, :is_utf_8
  end
end
