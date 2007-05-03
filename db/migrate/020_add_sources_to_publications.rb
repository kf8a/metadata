class AddSourcesToPublications < ActiveRecord::Migration
  def self.up
    add_column :publications, :source_id, :integer
    
    create_table :sources do |t|
        t.column :title, :string
    end
  end

  def self.down
    drop_table :sources
    remove_column :publications, :source_id
  end
end
