class AddDeprecationsToUnits < ActiveRecord::Migration[4.2]
  def self.up
    add_column :units, :deprecated_in_favor_of, :integer
  end

  def self.down
    remove_column :units, :deprecated_in_favor_of
  end
end
