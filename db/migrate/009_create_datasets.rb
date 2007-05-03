class CreateDatasets < ActiveRecord::Migration
  def self.up
    create_table :datasets do |t|
      t.column :dataset, :string
      t.column :title, :string
      t.column :abstract, :text
      t.column :keywords, :string
      t.column :status, :string
      t.column :initiated, :date
      t.column :completed, :date
      t.column :released, :date
      t.column :on_web, :boolean, :default => true  
      t.column :version, :int
    end
  end

  def self.down
    drop_table :datasets
  end
end
