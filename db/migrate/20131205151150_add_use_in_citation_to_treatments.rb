class AddUseInCitationToTreatments < ActiveRecord::Migration[4.2]
  def change
    add_column :treatments, :use_in_citations, :boolean, :default => true
  end
end
