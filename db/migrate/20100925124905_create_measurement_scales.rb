class CreateMeasurementScales < ActiveRecord::Migration
  def self.up
    create_table :measurement_scales do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :measurement_scales
  end
end
