class AddTypeToCitation < ActiveRecord::Migration
  def self.up
    add_column :citations, :type, :string
  end

  def self.down
    remove_column :citations, :type
  end
end
