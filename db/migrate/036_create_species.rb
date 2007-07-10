class CreateSpecies < ActiveRecord::Migration
  def self.up
    create_table :species do |t|
      t.column :species, :string
      t.column :genus, :string
      t.column :family, :string
      t.column :code, :string
      t.column :common_name, :string
      t.column :alternate_common_name, :string
      t.column :attribution, :string
      t.column :woody, :boolean
    end
  end

  def self.down
    drop_table :species
  end
end
