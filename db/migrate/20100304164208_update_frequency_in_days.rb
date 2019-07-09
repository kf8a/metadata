class UpdateFrequencyInDays < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :datatables, :update_frequency_years, :update_frequency_days
  end

  def self.down
    rename_column :datatables, :update_frequency_days, :update_frequency_years
  end
end
