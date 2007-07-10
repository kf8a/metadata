class CreateTreatments < ActiveRecord::Migration
  def self.up
    create_table :treatments do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :study_id, :integer
    end
    
    create_table :publications_treatments, :id => false do |t|
      t.column :treatment_id, :integer
      t.column :publication_id, :integer
    end
    Treatment.reset_column_information
    1.upto(8) do | t|
      Treatment.create(:name => "T#{t}")
    end
    Treatment.create(:name => "DF")
    Treatment.create(:name => "CF")
    Treatment.create(:name => 'SF')
    Treatment.create(:name => '2,4D')
    Treatment.create(:name => 'Biodiversity')
    Treatment.create(:name => 'ECB')
    
  end

  def self.down
    drop_table :publications_treatments
    drop_table :treatments
  end
end
