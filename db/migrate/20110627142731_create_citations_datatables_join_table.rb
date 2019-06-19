class CreateCitationsDatatablesJoinTable < ActiveRecord::Migration[4.2]
  def self.up
    create_table :citations_datatables, :id => false do |t|
      t.integer :citation_id
      t.integer :datatable_id
    end
  end

  def self.down
    drop_table :citations_datatables
  end
end
