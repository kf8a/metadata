class AddUpdateFrequency < ActiveRecord::Migration
  def self.up
    add_column :datatables, 'update_frequency_years', :integer
    add_column :datatables, "last_updated_on", :date
  end

  def self.down
    remove_column "datatables", "last_updated_on"
    remove_column "datatables", "update_frequency_years"
  end
end
