class VisualizationOrder < ActiveRecord::Migration
  def self.up
    add_column :visualizations, :weight, :integer
  end

  def self.down
    remove_column :visualizations, :weight
  end
end
