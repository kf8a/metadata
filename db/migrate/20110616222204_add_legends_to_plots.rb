class AddLegendsToPlots < ActiveRecord::Migration[4.2]
  def self.up
    add_column :visualizations, :x_axis_label, :string
    add_column :visualizations, :y_axis_label, :string
  end

  def self.down
    remove_column :visualizations, :x_axis_label
    remove_column :visualizations, :y_axes_label
  end
end
