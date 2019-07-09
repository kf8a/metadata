class AddCreatedAndUpdated < ActiveRecord::Migration[4.2]
  def self.up
    add_column :datatables, :created_at, :datetime
    add_column :datatables, :updated_at, :datetime
    add_column :datasets, :created_at, :datetime
    add_column :datasets, :updated_at, :datetime
  end

  def self.down
    remove_column :datasets, :updated_at
    remove_column :datasets, :created_at
    remove_column :datatables, :updated_at
    remove_column :datatables, :created_at
  end
end
