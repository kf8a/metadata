class ProtocolVersions < ActiveRecord::Migration
  def self.up
    add_column :protocols, :archived, :boolean
    add_column :protocols, :deprecated_in_favor_of, :integer
  end

  def self.down
    remove_column :protocols, :deprecated_in_favor_of
    remove_column :protocols, :archived
  end
end
