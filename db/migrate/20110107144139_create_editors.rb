class CreateEditors < ActiveRecord::Migration[4.2]
  def self.up
    create_table :editors do |t|
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
    drop_table :editors
  end
end
