class AddDatatableIdToCollections < ActiveRecord::Migration
  def self.up
    add_column :collections, :datatable_id, :integer
  end

  def self.down
    remove_column :collections, :datatable_id
  end
end
