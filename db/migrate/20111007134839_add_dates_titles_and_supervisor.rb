class AddDatesTitlesAndSupervisor < ActiveRecord::Migration
  def self.up
    add_column :affiliations, :supervisor, :string
    add_column :affiliations, :started_on, :date
    add_column :affiliations, :left_on, :date
    add_column :affiliations, :research_interest, :string
  end

  def self.down
    remove_column :affiliations, :research_interest
    remove_column :affiliations, :supervisor, :string
    remove_column :affiliations, :started_on, :date
    remove_column :affiliations, :left_on, :date
  end
end
