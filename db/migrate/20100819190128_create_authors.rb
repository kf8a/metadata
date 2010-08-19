class CreateAuthors < ActiveRecord::Migration
  def self.up
    create_table :authors do |t|
      t.string :sur_name
      t.string :given_name
      t.string :middle_name
      t.integer :seniority
      t.integer :person_id
      t.integer :citation_id
      t.timestamps
    end
  end

  def self.down
    drop_table :authors
  end
end
