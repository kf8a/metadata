class AddLinksToPdf < ActiveRecord::Migration
  def self.up
    add_column :publications, :file_url, :string
  end

  def self.down
    remove_column :publications, :file_url
  end
end
