class AddOwnerToPermissions < ActiveRecord::Migration
  def self.up
    add_column :permissions, :owner_id, :integer
  end

  def self.down
    remove_column :permissions, :owner_id
  end
end
