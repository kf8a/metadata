class AddTemporalExtentToDatatable < ActiveRecord::Migration[4.2]
  def self.up
    add_column :datatables, :begin_date, :date
    add_column :datatables, :end_date, :date
  end

  def self.down
    remove_column :datatables, :end_date
    remove_column :datatables, :begin_date
  end
end
