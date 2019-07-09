class AddEndDateToDatasets < ActiveRecord::Migration[4.2]
  def change
    add_column :datasets, :data_end_date, :date
  end
end
