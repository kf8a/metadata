class VisualizationOrder < ActiveRecord::Migration[4.2]
  def self.up
    add_column :visualizations, :weight, :integer
  end

  def self.down
    remove_column :visualizations, :weight
  end
end
