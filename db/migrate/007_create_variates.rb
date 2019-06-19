class CreateVariates < ActiveRecord::Migration[4.2]
  def self.up
    create_table :variates do |t|
      t.column :name, :string
      t.column :datatable_id, :int
      t.column :position, :int
      t.column :description, :text
      t.column :missing_value_indicator, :string
      t.column :unit_id, :int
      t.column :measurement_scale, :string
      t.column :data_type, :string
      t.column :min_valid, :float
      t.column :max_valid, :float
      t.column :precision, :float
      t.column :date_format, :string
    end
  end

  def self.down
    drop_table :variates
  end
end
