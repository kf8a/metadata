class AddIsSql < ActiveRecord::Migration[4.2]
  def self.up
    add_column "datatables", "is_sql", :boolean
  end

  def self.down
  end
end
