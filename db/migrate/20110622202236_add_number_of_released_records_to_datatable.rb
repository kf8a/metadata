class AddNumberOfReleasedRecordsToDatatable < ActiveRecord::Migration
  def self.up
    add_column :datatables, :number_of_released_records, :integer
  end

  def self.down
    remove_column :datatables, :number_of_released_records
  end
end
