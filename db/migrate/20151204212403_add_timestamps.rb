class AddTimestamps < ActiveRecord::Migration
  def change
    add_column :protocols, :updated_at, :timestamp
    add_column :protocols, :created_at, :timestamp
  end
end
