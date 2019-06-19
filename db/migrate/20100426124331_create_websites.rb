class CreateWebsites < ActiveRecord::Migration[4.2]
  def self.up
    create_table :websites do |t|
      t.string  :name
      t.timestamps
    end
    add_column :datatables, :website_id, :integer
  end

  def self.down
    remove_column :datatables, :website_id
    drop_table :websites
  end
end
