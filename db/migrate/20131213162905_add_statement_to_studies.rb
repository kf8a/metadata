class AddStatementToStudies < ActiveRecord::Migration
  def change
    add_column :studies, :warning, :text
  end
end
