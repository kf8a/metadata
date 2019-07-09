class MoveWebsiteToDataset < ActiveRecord::Migration[4.2]
  def self.up
    add_column :datasets, :website_id, :integer
    add_column :websites, :dataset_id, :integer

    remove_column :datatables, :website_id
  end

  def self.down
    add_column :datatables, :website_id, :integer
    remove_column :websites, :dataset_id
    remove_column :datasets, :website_id
  end
end
