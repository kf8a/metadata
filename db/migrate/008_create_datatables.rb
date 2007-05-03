class CreateDatatables < ActiveRecord::Migration
  def self.up
    create_table :datatables do |t|
      t.column :name, :string
      t.column :title, :string
      t.column :comments, :text
      t.column :dataset_id, :int
      t.column :data_url, :string
      t.column :connection_url, :string
      t.column :driver, :string
      t.column :is_restricted, :boolean
    end
  end

  def self.down
    drop_table :datatables
  end
end
