class AddStatementToStudies < ActiveRecord::Migration[4.2]
  def change
    add_column :studies, :warning, :text
  end
end
