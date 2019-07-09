class ProtocolVersions < ActiveRecord::Migration[4.2]
  def self.up
    add_column :protocols, :deprecates, :integer
    rename_column :protocols, :version, :version_tag
  end

  def self.down
    rename_column :protocols, :version_tag, :version
    remove_column :protocols, :deprecates
  end
end
