class AddActiveFlagToProtocol < ActiveRecord::Migration
  def self.up
    create_table :table_name, :force => true do |t|
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
      t.boolean "active",         :default => true
    end
  end

  def self.down
    drop_table :table_name
  end
end
