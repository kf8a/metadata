class CreateCitationsTreatmentsJoinTable < ActiveRecord::Migration[4.2]
  def self.up
    create_table :citations_treatments, :id => false do |t|
      t.integer :citation_id
      t.integer :treatment_id
    end
  end

  def self.down
    drop_table :citations_treatments
  end
end
