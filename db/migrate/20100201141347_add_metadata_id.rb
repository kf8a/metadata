class AddMetadataId < ActiveRecord::Migration
  def self.up
    add_column :datasets, :metacat_id, :integer
  end

  def self.down
    remove_column :datasets, :metacat_id
  end
end
