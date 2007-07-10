class CreateAreas < ActiveRecord::Migration
  def self.up
    create_table :areas do |t|
      t.column :name, :string
      t.column :treatment, :string
      t.column :replicate, :integer
      t.column :study_id, :integer
      t.column :description, :string
    end
    Area.reset_column_information
    1.upto(8) do |treat|
      1.upto(6) do |rep|
        Area.create(:name => "T#{treat}R#{rep}", :treatment => treat, :replicate => rep, :study_id => 1)
      end
    end
    ['CF','DF','SF'].each do |treat|
      1.upto(3) do |rep|
        Area.create(:name => "T#{treat}R#{rep}", :treatment => treat, :replicate => rep, :study_id => 1)
      end
    end
  end

  def self.down
    drop_table :areas
  end
end
