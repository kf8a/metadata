class AddDecisionToPermission < ActiveRecord::Migration[4.2]
  def self.up
    add_column :permissions, :decision, :string
  end

  def self.down
    remove_column :permissions, :decision
  end
end
