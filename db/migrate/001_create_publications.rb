class CreatePublications < ActiveRecord::Migration
  def self.up
    create_table :publications do |t|
      t.column :publication_type_id, :integer
      t.column :citation, :text
      t.column :abstract, :text
      t.column :year, :int
      t.column :authors, :string
      t.column :title, :string
    end
  end

  def self.down
    drop_table :publications
  end
end
