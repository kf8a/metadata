class CreateMemberships < ActiveRecord::Migration[4.2]
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
