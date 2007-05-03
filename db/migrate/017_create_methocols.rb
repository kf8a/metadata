class CreateMethocols < ActiveRecord::Migration
  def self.up
    create_table :methocols do |t|
      t.column :name, :string
      t.column :title, :string
      t.column :version, :int
      t.column :in_use_from, :date
      t.column :in_use_to, :date
      t.column :description, :text
      t.column :abstract, :text
      t.column :body, :text
      t.column :person_id, :int
      t.column :created_on, :date
      t.column :updated_on, :date
      t.column :change_summary, :text
      t.column :dataset_id, :int
    end
  end

  def self.down
    drop_table :methocols
  end
end
