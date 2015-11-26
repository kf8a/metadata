class AddArrivedDepartedDatesToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :arrived_on, :date
    add_column :roles, :departed_on, :date
  end
end
