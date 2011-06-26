class AddUnitLabel < ActiveRecord::Migration
  def self.up
    add_column :units, :label, :string
  end

  def self.down
    remove_column :units, :label
  end
end
