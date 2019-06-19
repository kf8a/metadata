class AddOrchidIdToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :orcid_id, :string
  end
end
