class ConvertThemeToTree < ActiveRecord::Migration
  def self.up
    add_column :themes, :parent_id, :integer
    add_column :themes, :lft, :integer
    add_column :themes, :rgt, :integer
  end

  def self.down
    remove_column :themes, :rgt
    remove_column :themes, :lft
    remove_column :themes, :parent_id
  end
end
