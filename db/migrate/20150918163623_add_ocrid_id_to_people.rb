class AddOcridIdToPeople < ActiveRecord::Migration
  def change
    add_column :people, :orcid, :string
  end
end
