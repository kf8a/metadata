class RemovePdfFieldFromCitation < ActiveRecord::Migration
  def self.up
    remove_column :citations, :pdf  
  end

  def self.down
    add_column :citations, :pdf, :string
  end
end
