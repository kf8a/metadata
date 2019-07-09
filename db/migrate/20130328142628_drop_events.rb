class DropEvents < ActiveRecord::Migration[4.2]
  def up
    remove_column :datatables, :event_query
    drop_table :events
  end
end
