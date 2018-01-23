class CreateDatasetDois < ActiveRecord::Migration
  def change
    create_table :dataset_dois do |t|
      t.integer :dataset_id
      t.string :doi

      t.timestamps null: false
    end
  end
end
