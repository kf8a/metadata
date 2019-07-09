class AddActiveFlagToProtocol < ActiveRecord::Migration[4.2]
  def self.up
    add_column "protocols", "active", :boolean, :default=>true
  end

  def self.down
    remove_column "protocols", "active"
  end
end
