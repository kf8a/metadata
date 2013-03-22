class AddEndDateToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :data_end_date, :date
  end
end
