class SponsorDataPolicy < ActiveRecord::Migration
  def self.up
    add_column :sponsors, :data_restricted, :boolean, :default => false
  end

  def self.down
    remove_column :sponsors, :data_restricted
  end
end
