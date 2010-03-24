class StudyToNestedSet < ActiveRecord::Migration
  def self.up
    add_column :studies, :parent_id, :integer
    add_column :studies, :lft, :integer
    add_column :studies, :rgt, :integer
    
    Study.reset_column_information
    
    Study.rebuild!
  end

  def self.down
    remove_column :studies, :rgt
    remove_column :studies, :lft
    remove_column :studies, :parent_id
  end
end
