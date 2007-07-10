class CreateDatatablesVariates < ActiveRecord::Migration
  def self.up
    create_table :datatables_variates do |t|
    end
  end

  def self.down
    drop_table :datatables_variates
  end
end
