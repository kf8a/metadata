class CreateUnits < ActiveRecord::Migration
  def self.up
    create_table :units do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :in_eml, :boolean, :default=>false
      t.column :definition, :text
    end
  end

  def self.down
    drop_table :units
  end
end
