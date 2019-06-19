class AddUnitLabel < ActiveRecord::Migration[4.2]
  def self.up
    add_column :units, :label, :string
  end

  def self.down
    remove_column :units, :label
  end
end
