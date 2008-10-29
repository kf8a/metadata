class AddPublicationFileUpload < ActiveRecord::Migration
  def self.up
    add_column :publications, :parent_id, :integer
    add_column :publications, :content_type, :string
    add_column :publications, :filename, :string
    add_column :publications, :size, :integer
    add_column :publications, :width, :integer
    add_column :publications, :height, :integer
  end

  def self.down
    remove_column :publications, :height
    remove_column :publications, :width
    remove_column :publications, :size
    remove_column :publications, :filename
    remove_column :publications, :content_type
    remove_column :publications, :parent_id
  end
end
