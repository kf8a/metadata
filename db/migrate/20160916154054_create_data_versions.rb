class CreateDataVersions < ActiveRecord::Migration
  def change
    create_table :data_versions do |t|
      t.integer :dataset_id
      t.string :doi

      t.timestamps null: false
    end
  end
end
