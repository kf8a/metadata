class CreateSpecimenImages < ActiveRecord::Migration
  def self.up
    create_table :specimen_images do |t|
      t.integer :specimen_id
      t.string :code
      t.text :description
      
      t.string :author
      t.date :date
      t.boolean :species_photo
      t.boolean :active
      
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :specimen_images
  end
end
