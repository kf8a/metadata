class PageNumbersToStrings < ActiveRecord::Migration
  def self.up
    change_column :citations, :start_page_number, :string
    change_column :citations, :ending_page_number, :string
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
