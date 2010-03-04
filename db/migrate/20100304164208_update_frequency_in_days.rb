class UpdateFrequencyInDays < ActiveRecord::Migration
  def self.up
    rename_column :datatables, :update_frequency_years, :update_frequency_days
  end

  def self.down
    rename_column :datatables, :update_frequency_days, :update_frequency_years
  end
end
