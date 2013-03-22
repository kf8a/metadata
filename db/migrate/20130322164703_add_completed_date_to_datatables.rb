class AddCompletedDateToDatatables < ActiveRecord::Migration
  def change
    add_column :datatables, :completed_on, :date
  end
end
