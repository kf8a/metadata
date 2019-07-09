class CreateDatasetFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :dataset_files do |t|
      t.text :name
      t.integer :dataset_id

      t.timestamps
    end
  end
end
