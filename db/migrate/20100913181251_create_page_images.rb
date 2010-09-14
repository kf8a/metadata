class CreatePageImages < ActiveRecord::Migration
  def self.up
    create_table :page_images do |t|
      t.string    :title
      t.string    :attribution
      t.integer   :page_id
      t.string    :image_file_name
      t.string    :image_content_type
      t.integer   :image_file_size
      t.datetime  :image_updated_at
    end
  end

  def self.down
    drop_table :page_images
  end
end
