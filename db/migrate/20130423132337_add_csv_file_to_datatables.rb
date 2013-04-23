class AddCsvFileToDatatables < ActiveRecord::Migration
  def change
    add_attachment :datatables, :csv_cache
  end
end
