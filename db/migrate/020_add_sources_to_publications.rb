class AddSourcesToPublications < ActiveRecord::Migration
  def self.up
    add_column :publications, :source_id, :integer
    add_column :publications, :parent_id, :integer
    
    # Paperclip
    add_column :publications, :content_type, :string
    add_column :publications, :filename, :string
    add_column :publications, :size, :integer
    add_column :publications, :width, :integer
    add_column :publications, :height, :integer
    
    create_table :sources do |t|
        t.column :title, :string
    end
  end

  def self.down
    drop_table :sources
    remove_column :publications, :height
    remove_column :publications, :width
    remove_column :publications, :size
    remove_column :publications, :filename
    remove_column :publications, :content_type
    remove_column :publications, :parent_id
    remove_column :publications, :source_id
  end
end
