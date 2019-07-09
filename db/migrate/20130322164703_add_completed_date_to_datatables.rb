class AddCompletedDateToDatatables < ActiveRecord::Migration[4.2]
  def change
    add_column :datatables, :completed_on, :date
  end
end
