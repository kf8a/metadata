class AddOwnerToPermissions < ActiveRecord::Migration[4.2]
  def self.up
    add_column :permissions, :owner_id, :integer
  end

  def self.down
    remove_column :permissions, :owner_id
  end
end
