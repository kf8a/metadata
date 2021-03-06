class AddStudyDescription < ActiveRecord::Migration[4.2]
  def self.up
    add_column :studies, :description, :text
    add_column :studies, :seniority, :integer
  end

  def self.down
    remove_column :studies, :seniority
    remove_column :studies, :description
  end
end
