class DropEvents < ActiveRecord::Migration
  def up
    remove_column :datatables, :event_query
    drop_table :events
  end
end
