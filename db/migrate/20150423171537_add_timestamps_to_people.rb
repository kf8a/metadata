class AddTimestampsToPeople < ActiveRecord::Migration
  def change
    add_column :people, :updated_at, :timestamp
    add_column :people, :created_at, :timestamp
  end
end
