class AddOrchidIdToPerson < ActiveRecord::Migration
  def change
    add_column :people, :orchid_id, :string
  end
end
