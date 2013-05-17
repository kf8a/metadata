class CreateDatasetFiles < ActiveRecord::Migration
  def change
    create_table :dataset_files do |t|
      t.text :name
      t.integer :dataset_id

      t.timestamps
    end
  end
end
