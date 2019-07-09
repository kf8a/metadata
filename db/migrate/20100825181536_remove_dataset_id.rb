class RemoveDatasetId < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :websites, :dataset_id
  end

  def self.down
  end
end
