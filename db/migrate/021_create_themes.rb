class CreateThemes < ActiveRecord::Migration
  def self.up
    create_table :themes do |t|
      t.column :title, :string
      t.column :priority, :int
    end
  end

  def self.down
    drop_table :themes
  end
end
