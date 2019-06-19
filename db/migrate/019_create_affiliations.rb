class CreateAffiliations < ActiveRecord::Migration[4.2]
  def self.up
    create_table :affiliations do |t|
      t.column :person_id, :int
      t.column :role_id, :int
      t.column :dataset_id, :int
      t.column :seniority, :int
    end
  end

  def self.down
    drop_table :affiliations
  end
end
