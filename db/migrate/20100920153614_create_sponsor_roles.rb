class CreateSponsorRoles < ActiveRecord::Migration
  def self.up
    create_table :sponsor_roles do |t|
      t.integer :sponsor_id
      t.integer :user_id
      t.string  :role
    end
  end

  def self.down
    drop_table :sponsor_roles
  end
end
