class CreateUploads < ActiveRecord::Migration[4.2]
  def self.up
    create_table :uploads do |t|
      t.string  "title", "owners"
      t.text    "abstract"
      t.binary  "file"
      t.timestamps
    end
  end

  def self.down
    drop_table :uploads
  end
end
