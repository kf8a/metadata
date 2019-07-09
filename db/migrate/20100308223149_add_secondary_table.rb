class AddSecondaryTable < ActiveRecord::Migration[4.2]
  def self.up
    add_column :datatables, :is_secondary, :boolean, :default => false
    
    Datatable.reset_column_information
    Datatable.all.each do |d|
      d.theme.nil? ? d.is_secondary = true : d.is_secondary = false
      d.save
    end
  end

  def self.down
    remove_column :datatables, :is_secondary
  end
end
