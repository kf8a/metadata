class CreateRoleTypes < ActiveRecord::Migration
  def self.up
    create_table :role_types do |t|
      t.column :name, :string
    end
    add_column :roles, :role_type_id, :integer
    add_column :roles,  :seniority, :integer
  end

  def self.down
    remove_column :roles, :role_type_id
    remove_column :roles, :seniority, :integer
    drop_table :role_types
  end
end
