class AddOrchidIdToPerson < ActiveRecord::Migration
  def change
    add_column :people, :orcid_id, :string
  end
end
