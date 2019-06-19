class CreateDataContributions < ActiveRecord::Migration[4.2]
  def self.up
    create_table :data_contributions do |t|
      t.integer :person_id
      t.integer :datatable_id
      t.integer :role_id
      t.timestamps
    end
    execute 'create unique index data_contributions_uniq_idx on data_contributions(datatable_id, person_id, role_id)'
    
  end

  def self.down
    drop_table :data_contributions
  end
end
