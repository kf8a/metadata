class CreatePermissionRequests < ActiveRecord::Migration
  def self.up
    create_table :permission_requests do |t|
      t.integer :datatable_id
      t.integer :user_id
      t.boolean :denied
      t.timestamps
    end
  end

  def self.down
    drop_table :permission_requests
  end
end
