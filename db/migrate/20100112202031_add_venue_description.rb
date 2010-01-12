class AddVenueDescription < ActiveRecord::Migration
  def self.up
    add_column :venue_types, :description, :text
  end

  def self.down
    remove_column :venue_types, :description
  end
end
