class AddTimestampsToStudiesAndThemes < ActiveRecord::Migration[4.2]
  def change
    add_column :studies, :updated_at, :datetime
    add_column :studies, :created_at, :datetime
    add_column :themes, :updated_at, :datetime
    add_column :themes, :created_at, :datetime
  end
end
