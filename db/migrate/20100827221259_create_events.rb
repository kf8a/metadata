class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :title
      t.datetime :start
      t.datetime :end
      t.text :caption
      t.text :description
      t.timestamps
    end
    add_column :datatables, :event_query, :text
  end

  def self.down
    remove_column :datatables, :event_query
    drop_table :events
  end
end
