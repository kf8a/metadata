class DatasetsThemes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :datasets_themes, :id => false do  |t|
      t.column :theme_id, :int
      t.column :dataset_id, :int
    end
  end

  def self.down
    drop_table :datasets_themes
  end
end
