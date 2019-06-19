class ExpandUnitDefinition < ActiveRecord::Migration[4.2]
  def self.up
    add_column :units, :unit_type, :string
    add_column :units, :parent_si, :string
    add_column :units, :multiplier_to_si, :real
  end

  def self.down
    remove_column :units, :multiplier_to_si
    remove_column :units, :parent_si
    remove_column :units, :unit_type
  end
end
