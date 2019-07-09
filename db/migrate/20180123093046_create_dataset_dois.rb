class CreateDatasetDois < ActiveRecord::Migration[4.2]
  def change
    create_table :dataset_dois do |t|
      t.integer :dataset_id
      t.string :doi

      t.timestamps null: false
    end
  end
end
