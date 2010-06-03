class CreateDatafiles < ActiveRecord::Migration
  def self.up
    create_table :datafiles do |t|
      t.text :title
      t.text :description
      t.string :original_data_file_name
      t.string :original_data_content_type
      t.integer :original_data_file_size
      t.integer :person_id
      t.timestamps
    end
  end

  def self.down
    drop_table :datafiles
  end
end
