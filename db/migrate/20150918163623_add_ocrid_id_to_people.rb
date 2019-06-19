class AddOcridIdToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :orcid, :string
  end
end
