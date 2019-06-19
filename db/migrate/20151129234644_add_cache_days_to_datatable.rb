class AddCacheDaysToDatatable < ActiveRecord::Migration[4.2]
  def change
    add_column :datatables, :update_cache_days, :integer
  end
end
