class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.integer :sponsor_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :memberships
  end
end
