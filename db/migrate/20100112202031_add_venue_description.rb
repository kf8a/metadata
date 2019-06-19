class AddVenueDescription < ActiveRecord::Migration[4.2]
  def self.up
    add_column :venue_types, :description, :text
  end

  def self.down
    remove_column :venue_types, :description
  end
end
