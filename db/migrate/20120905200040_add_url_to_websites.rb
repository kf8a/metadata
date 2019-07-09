class AddUrlToWebsites < ActiveRecord::Migration[4.2]
  def self.up
    add_column :websites, :url, :text
  end

  def self.down
    remove_column :websites, :url
  end
end
