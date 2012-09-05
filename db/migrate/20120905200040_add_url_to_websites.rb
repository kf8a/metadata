class AddUrlToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :url, :text
  end

  def self.down
    remove_column :websites, :url
  end
end
