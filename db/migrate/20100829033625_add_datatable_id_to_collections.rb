class AddDatatableIdToCollections < ActiveRecord::Migration[4.2]
  def self.up
    add_column :collections, :datatable_id, :integer
  end

  def self.down
    remove_column :collections, :datatable_id
  end
end
