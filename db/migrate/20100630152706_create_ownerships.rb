class CreateOwnerships < ActiveRecord::Migration[4.2]
  def self.up
    create_table :ownerships do |t|
      t.integer :datatable_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :ownerships
  end
end
