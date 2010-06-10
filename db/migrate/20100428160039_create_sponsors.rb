class CreateSponsors < ActiveRecord::Migration
  def self.up
    create_table :sponsors do |t|
      t.string  :name
      t.timestamps
    end
    add_column :datasets, :sonsor_id, :integer
  end

  def self.down
    remove_column :datasets, :sonsor_id
    drop_table :sponsors
  end
end
