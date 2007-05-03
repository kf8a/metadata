class RemoveUsers < ActiveRecord::Migration
  def self.up
    drop_table :users
  end

  def self.down
    create_table "users"  do |t|
      t.column "open_id", :string
      t.column "email",   :string
      t.column "role_id", :integer
    end
  end
end
