class RenameCitationUrl < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :citations, :url, :publisher_url
  end

  def self.down
    rename_column :citations, :publisher_url, :url
  end
end
