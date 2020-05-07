class CreatePersonProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :person_projects do |t|
      t.column :person_id, :integer
      t.column :project_id, :integer
      t.column :role_id, :integer
      t.timestamps
    end
  end
end
