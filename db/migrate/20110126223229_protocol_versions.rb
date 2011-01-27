class ProtocolVersions < ActiveRecord::Migration
  def self.up
    add_column :protocols, :deprecates, :integer
  end

  def self.down
    remove_column :protocols, :deprecates
  end
end
