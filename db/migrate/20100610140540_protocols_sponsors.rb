class ProtocolsSponsors < ActiveRecord::Migration
  def self.up
    create_table :protocols_sponsors, :id => false do |t|
      t.integer :protocol_id
      t.integer :sponsor_id
    end
  end

  def self.down
    drop_table :protocols_sponsors
  end
end
