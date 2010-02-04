class AddTemporalExtentToDatatable < ActiveRecord::Migration
  def self.up
    add_column :datatables, :begin_date, :date
    add_column :datatables, :end_date, :date
  end

  def self.down
    remove_column :datatables, :end_date
    remove_column :datatables, :begin_date
  end
end
