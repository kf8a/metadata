class MaterializedDatatable
  include MongoMapper::Document
  enable_versioning  :limit => 0

  key :datatable, Integer 
  key :values, Array
  key :fields, Array
end
