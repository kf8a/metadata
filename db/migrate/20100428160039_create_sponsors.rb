class CreateSponsors < ActiveRecord::Migration[4.2]
  def self.up
    create_table :sponsors do |t|
      t.string  :name
      t.timestamps
    end
    add_column :datasets, :sponsor_id, :integer
  end

  def self.down
    remove_column :datasets, :sponsor_id
    drop_table :sponsors
  end
end
