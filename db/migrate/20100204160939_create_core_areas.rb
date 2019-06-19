class CreateCoreAreas < ActiveRecord::Migration[4.2]
  def self.up
    create_table :core_areas do |t|
      t.string  :name
    end
  end

  def self.down
    drop_table :core_areas
  end
end
