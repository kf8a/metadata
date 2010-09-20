class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.integer :sponsor_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :members
  end
end
