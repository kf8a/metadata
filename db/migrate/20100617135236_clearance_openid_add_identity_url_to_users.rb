class ClearanceOpenidAddIdentityUrlToUsers < ActiveRecord::Migration[4.2]

  def self.up
    add_column :users, :identity_url, :string
    add_index :users, :identity_url, :unique => true
  end
 
  def self.down
    remove_column :users, :identity_url
  end

end
