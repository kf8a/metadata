class RemoveDeniedFromPermissionRequest < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :permission_requests, :denied
  end

  def self.down
    add_column    :permission_requests, :denied, :boolean
  end
end
