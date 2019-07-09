class AddSourceToStudies < ActiveRecord::Migration[4.2]
  def change
    add_column :studies, :source, :text
    add_column :studies, :old_names, :text
  end
end
