class AddDecisionToPermission < ActiveRecord::Migration
  def self.up
    add_column :permissions, :decision, :string
  end

  def self.down
    remove_column :permissions, :decision
  end
end
