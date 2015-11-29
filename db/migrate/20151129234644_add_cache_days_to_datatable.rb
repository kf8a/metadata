class AddCacheDaysToDatatable < ActiveRecord::Migration
  def change
    add_column :datatables, :update_cache_days, :integer
  end
end
