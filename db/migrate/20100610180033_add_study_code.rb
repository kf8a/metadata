class AddStudyCode < ActiveRecord::Migration
  def self.up
    add_column :studies, :code, :string
  end

  def self.down
    remove_column :studies, :code
  end
end
