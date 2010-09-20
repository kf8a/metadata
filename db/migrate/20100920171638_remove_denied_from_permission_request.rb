class RemoveDeniedFromPermissionRequest < ActiveRecord::Migration
  def self.up
    remove_column :permission_requests, :denied
  end

  def self.down
    add_column    :permission_requests, :denied, :boolean
  end
end
