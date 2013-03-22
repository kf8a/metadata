class AddScoresToDatatables < ActiveRecord::Migration
  def change
    add_column :datatables, :scores, :text
  end
end
