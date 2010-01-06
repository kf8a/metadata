class AddRoleVisibility < ActiveRecord::Migration
  def self.up
    add_column :roles, :show_in_overview, :boolean, :default => true
    add_column :roles, :show_in_detailview, :boolean, :default => true
  end

  def self.down
    remove_column :roles, :show_in_detailview
    remove_column :roles, :show_in_overview
  end
end
