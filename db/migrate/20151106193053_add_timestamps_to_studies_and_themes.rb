class AddTimestampsToStudiesAndThemes < ActiveRecord::Migration
  def change
    add_column :studies, :updated_at, :datetime
    add_column :studies, :created_at, :datetime
    add_column :themes, :updated_at, :datetime
    add_column :themes, :created_at, :datetime
  end
end
