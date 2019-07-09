class AddBoundingCoordinateField < ActiveRecord::Migration[4.2]
  def change
    add_column :datasets, :west_bounding_coordinate, :float
    add_column :datasets, :east_bounding_coordinate, :float
    add_column :datasets, :north_bounding_coordinate, :float
    add_column :datasets, :south_bounding_coordinate, :float
  end
end
