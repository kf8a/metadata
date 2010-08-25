class RemoveDatasetId < ActiveRecord::Migration
  def self.up
    remove_column :websites, :dataset_id
  end

  def self.down
  end
end
