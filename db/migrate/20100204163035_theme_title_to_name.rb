class ThemeTitleToName < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :themes, :title, :name
  end

  def self.down
    rename_column :themes, :name, :title
  end
end
