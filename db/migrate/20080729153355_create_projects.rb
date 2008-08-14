class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :title
      t.text :abstract

      t.timestamps
    end
    add_column :datasets, :project_id, :integer
  end

  def self.down
    remove_column :datasets, :project_id
    drop_table :projects
  end
end
