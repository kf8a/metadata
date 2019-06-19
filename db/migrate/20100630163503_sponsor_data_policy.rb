class SponsorDataPolicy < ActiveRecord::Migration[4.2]
  def self.up
    add_column :sponsors, :data_restricted, :boolean, :default => false
  end

  def self.down
    remove_column :sponsors, :data_restricted
  end
end
