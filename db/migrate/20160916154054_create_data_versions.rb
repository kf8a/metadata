class CreateDataVersions < ActiveRecord::Migration[4.2]
  def change
    create_table :data_versions do |t|
      t.integer :dataset_id
      t.string :doi

      t.timestamps null: false
    end
  end
end
