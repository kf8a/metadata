class AddDataCatalogIntro < ActiveRecord::Migration[4.2]
  def self.up
    add_column :websites, :data_catalog_intro, :text
  end

  def self.down
    remove_column :websites, :data_catalog_intro
  end
end
