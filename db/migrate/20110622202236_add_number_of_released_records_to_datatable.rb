class AddNumberOfReleasedRecordsToDatatable < ActiveRecord::Migration
  def change
    add_column :datatables, :number_of_released_records, :integer
    add_column :datatables, :access_statement, :text
  end

end
