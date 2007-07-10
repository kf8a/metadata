class AddIsSql < ActiveRecord::Migration
  def self.up
    add_column "datatables", "is_sql", :boolean
  end

  def self.down
  end
end
