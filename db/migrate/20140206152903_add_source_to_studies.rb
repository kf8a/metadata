class AddSourceToStudies < ActiveRecord::Migration
  def change
    add_column :studies, :source, :text
    add_column :studies, :old_names, :text
  end
end
