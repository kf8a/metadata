class AddAffiliationTitle < ActiveRecord::Migration
  def self.up
    add_column :affiliations, :title, :string
  end

  def self.down
    remove_column :affiliations, :title
  end
end
