class AddAffiliationTitle < ActiveRecord::Migration[4.2]
  def self.up
    add_column :affiliations, :title, :string
  end

  def self.down
    remove_column :affiliations, :title
  end
end
