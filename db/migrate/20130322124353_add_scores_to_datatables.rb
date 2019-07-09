class AddScoresToDatatables < ActiveRecord::Migration[4.2]
  def change
    add_column :datatables, :scores, :text
  end
end
