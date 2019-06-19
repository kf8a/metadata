class CreateDatasets < ActiveRecord::Migration[4.2]
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

    create_table "protocols", :force => true do |t|
       t.string  "name"
       t.string  "title"
       t.integer "version"
       t.date    "in_use_from"
       t.date    "in_use_to"
       t.text    "description"
       t.text    "abstract"
       t.text    "body"
       t.integer "person_id"
       t.date    "created_on"
       t.date    "updated_on"
       t.text    "change_summary"
       t.integer "dataset_id"
     end
  end

  def self.down
    drop_table :datasets
  end
end
