class CreateHerbaria < ActiveRecord::Migration
  def self.up
    create_table :herbaria do |t|
      t.string  :title
      t.text    :abstract
      t.timestamps
    end
  end

  def self.down
    drop_table :herbaria
  end
end
