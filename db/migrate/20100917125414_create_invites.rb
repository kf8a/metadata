class CreateInvites < ActiveRecord::Migration[4.2]
  def self.up
    create_table :invites do |t|
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :invite_code, :limit => 40
      t.datetime :invited_at
      t.datetime :redeemed_at
      t.boolean :glbrc_member
    end
    
    add_index :invites, [:id, :email]
    add_index :invites, [:id, :invite_code]
  end

  def self.down
    drop_table :invites
  end
end
