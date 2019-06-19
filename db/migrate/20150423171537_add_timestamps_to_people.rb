class AddTimestampsToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :updated_at, :timestamp
    add_column :people, :created_at, :timestamp
  end
end
