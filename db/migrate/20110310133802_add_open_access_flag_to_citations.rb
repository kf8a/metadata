class AddOpenAccessFlagToCitations < ActiveRecord::Migration
  def self.up
    add_column :citations, :open_access, :boolean, :default=>false
  end

  def self.down
    remove_column :citations, :open_access
  end
end
