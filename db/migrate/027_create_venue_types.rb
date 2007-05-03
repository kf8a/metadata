class CreateVenueTypes < ActiveRecord::Migration
  def self.up
    create_table :venue_types do |t|
      t.column :name, :string
    end
    add_column "meetings", "venue_type_id", :integer
  end

  def self.down
    drop_table :venue_types
    remove_column "meetings", "venue_type_id"
  end
end
