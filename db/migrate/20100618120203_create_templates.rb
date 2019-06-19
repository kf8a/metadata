class CreateTemplates < ActiveRecord::Migration[4.2]
  def self.up
    create_table :templates do |t|
      t.integer :website_id
      t.string :controller
      t.string :action
      t.text :layout

      t.timestamps
    end
  end

  def self.down
    drop_table :templates
  end
end
