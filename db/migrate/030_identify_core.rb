class IdentifyCore < ActiveRecord::Migration
  def self.up
    add_column "datasets", "core_dataset", :boolean, :default => false
  end

  def self.down
    remove_column "datasets", "core_dataset"
  end
end
