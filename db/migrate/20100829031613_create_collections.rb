class CreateCollections < ActiveRecord::Migration[4.2]
  def self.up
    create_table :collections do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :collections
  end
end
