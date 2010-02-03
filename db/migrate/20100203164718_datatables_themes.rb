class DatatablesThemes < ActiveRecord::Migration
  def self.up
    create_table :datatables_themes, :id => false, :force => true do |t|
      t.integer :datatable_id
      t.integer :theme_ids
      t.timestamps
    end
  end

  def self.down
    drop_table :datatables_themes
  end
end
