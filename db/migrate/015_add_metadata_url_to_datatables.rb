class AddMetadataUrlToDatatables < ActiveRecord::Migration[4.2]
  def self.up
    add_column "datatables", "object", :string
    add_column "datatables", "metadata_url", :string
  end

  def self.down
    remove_column "datatables", "object"
    remove_column "datatables", "metadata_url"
  end
end
