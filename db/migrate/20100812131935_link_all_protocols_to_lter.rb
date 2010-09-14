class LinkAllProtocolsToLter < ActiveRecord::Migration
  def self.up
    website = Website.find(1)
    Protocol.all.each do |prot|
      website.protocols << prot
      website.save
    end
  end

  def self.down
  end
end
