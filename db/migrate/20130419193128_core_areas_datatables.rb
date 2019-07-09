class CoreAreasDatatables < ActiveRecord::Migration[4.2]
  def up
    create_table :core_areas_datatables do |t|
      t.integer :core_area_id
      t.integer :datatable_id
    end

    CoreArea.reset_column_information
    Datatable.reset_column_information

    Datatable.all.each do |datatable|
      core_id = datatable.core_area_id
      if core_id
        area = CoreArea.find(core_id)
        datatable.core_areas << area
        datatable.save
      end
    end
  end

  def down
    drop_table core_areas_datatables
  end
end
