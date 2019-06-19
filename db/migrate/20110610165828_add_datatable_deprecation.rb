class AddDatatableDeprecation < ActiveRecord::Migration[4.2]
  def self.up
    add_column :datatables, :deprecated_in_fovor_of, :integer
    add_column :datatables, :deprecation_notice, :text
  end

  def self.down
    remove_column :datatables, :deprecation_notice
    remove_column :datatables, :deprecated_in_fovor_of, :integer
  end
end
