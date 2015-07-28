class MetadataOnly < ActiveRecord::Migration
  def self.up
    add_column :datatables, :metadata_only, :boolean, :default=>false

    Datatable.reset_column_information
    Datatable.all.each do | table |
      table.metadata_only = false
      table.save
    end
  end

  def self.down
    remove_column :datatables, :metadata_only
  end
end
