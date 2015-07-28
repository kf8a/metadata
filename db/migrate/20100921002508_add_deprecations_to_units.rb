class AddDeprecationsToUnits < ActiveRecord::Migration
  def self.up
    add_column :units, :deprecated_in_favor_of, :integer
  end

  def self.down
    remove_column :units, :deprecated_in_favor_of
  end
end
