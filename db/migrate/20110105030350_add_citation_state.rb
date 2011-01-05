class AddCitationState < ActiveRecord::Migration
  def self.up
    add_column :citations, :state, :string
  end

  def self.down
    remove_column :citations, :state
  end
end
