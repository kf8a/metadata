class MoveSponsorToDatatable < ActiveRecord::Migration[6.0]
  def change
    add_column :datatables, :sponsor_id, :integer
  end
end
