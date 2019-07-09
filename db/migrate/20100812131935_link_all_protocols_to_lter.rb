class LinkAllProtocolsToLter < ActiveRecord::Migration[4.2]
  def self.up
    website = Website.first
    if website
      Protocol.all.each do |prot|
        website.protocols << prot
        website.save
      end
    end
  end

  def self.down
  end
end
