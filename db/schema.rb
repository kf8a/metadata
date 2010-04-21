# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100421190055) do

  create_table "affiliations", :force => true do |t|
    t.integer "person_id"
    t.integer "role_id"
    t.integer "dataset_id"
    t.integer "seniority"
    t.string  "title"
  end

  create_table "citations", :force => true do |t|
    t.date     "datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "columns", :force => true do |t|
    t.integer "datatable_id"
    t.integer "variate_id"
    t.integer "position"
    t.string  "name"
  end

  create_table "core_areas", :force => true do |t|
    t.string "name"
  end

  create_table "data_contributions", :force => true do |t|
    t.integer  "person_id"
    t.integer  "datatable_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "data_contributions", ["datatable_id", "person_id", "role_id"], :name => "data_contributions_uniq_idx", :unique => true

  create_table "datasets", :force => true do |t|
    t.string   "dataset"
    t.string   "title"
    t.text     "abstract"
    t.string   "old_keywords"
    t.string   "status"
    t.date     "initiated"
    t.date     "completed"
    t.date     "released"
    t.boolean  "on_web",       :default => true
    t.integer  "version"
    t.boolean  "core_dataset", :default => false
    t.integer  "project_id"
    t.integer  "metacat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "datasets", ["dataset"], :name => "datasets_dataset_key", :unique => true

  create_table "datasets_studies", :id => false, :force => true do |t|
    t.integer "dataset_id"
    t.integer "study_id"
  end

  create_table "datasets_themes", :id => false, :force => true do |t|
    t.integer "theme_id"
    t.integer "dataset_id"
  end

  create_table "datatables", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.text     "comments"
    t.integer  "dataset_id"
    t.string   "data_url"
    t.string   "connection_url"
    t.string   "driver"
    t.boolean  "is_restricted"
    t.text     "description"
    t.text     "object"
    t.string   "metadata_url"
    t.boolean  "is_sql"
    t.integer  "update_frequency_days"
    t.date     "last_updated_on"
    t.text     "access_statement"
    t.integer  "excerpt_limit"
    t.date     "begin_date"
    t.date     "end_date"
    t.boolean  "on_web",                :default => true
    t.integer  "theme_id"
    t.integer  "core_area_id"
    t.integer  "weight",                :default => 100
    t.integer  "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_secondary",          :default => false
  end

  create_table "datatables_variates", :force => true do |t|
  end

  create_table "eml_docs", :force => true do |t|
  end

  create_table "geometry_columns", :id => false, :force => true do |t|
    t.string  "f_table_catalog",   :limit => 256, :null => false
    t.string  "f_table_schema",    :limit => 256, :null => false
    t.string  "f_table_name",      :limit => 256, :null => false
    t.string  "f_geometry_column", :limit => 256, :null => false
    t.integer "coord_dimension",                  :null => false
    t.integer "srid",                             :null => false
    t.string  "type",              :limit => 30,  :null => false
  end

  create_table "log_hiresyieldmanagement", :id => false, :force => true do |t|
    t.date    "obsdate"
    t.integer "obsnumber"
    t.string  "author"
    t.text    "observation"
  end

  create_table "meeting_abstracts", :force => true do |t|
    t.text    "title"
    t.text    "authors"
    t.text    "abstract"
    t.integer "meeting_id"
  end

  create_table "meetings", :force => true do |t|
    t.date    "date"
    t.string  "title"
    t.text    "announcement"
    t.integer "venue_type_id"
    t.date    "date_to"
  end

  create_table "open_id_associations", :force => true do |t|
    t.binary  "server_url"
    t.string  "handle"
    t.binary  "secret"
    t.integer "issued"
    t.integer "lifetime"
    t.string  "assoc_type"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "open_id_nonces", :force => true do |t|
    t.string  "nonce"
    t.integer "created"
  end

  create_table "open_id_settings", :force => true do |t|
    t.string "setting"
    t.binary "value"
  end

  create_table "people", :force => true do |t|
    t.string  "person"
    t.string  "sur_name"
    t.string  "given_name"
    t.string  "middle_name"
    t.string  "friendly_name"
    t.string  "title"
    t.string  "sub_organization"
    t.string  "organization"
    t.string  "street_address"
    t.string  "city"
    t.string  "locale"
    t.string  "country"
    t.string  "postal_code"
    t.string  "phone"
    t.string  "fax"
    t.string  "email"
    t.string  "url"
    t.boolean "deceased"
    t.string  "open_id"
  end

  create_table "projects", :force => true do |t|
    t.string   "title"
    t.text     "abstract"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "protocols", :force => true do |t|
    t.string  "name"
    t.string  "title"
    t.integer "version"
    t.date    "in_use_from"
    t.date    "in_use_to"
    t.text    "description"
    t.text    "abstract"
    t.text    "body"
    t.integer "person_id"
    t.date    "created_on"
    t.date    "updated_on"
    t.text    "change_summary"
    t.integer "dataset_id"
    t.boolean "active",         :default => true
  end

  create_table "publication_types", :force => true do |t|
    t.string "name"
  end

  create_table "publications", :force => true do |t|
    t.integer "publication_type_id"
    t.text    "citation"
    t.text    "abstract"
    t.integer "year"
    t.string  "file_url"
    t.text    "title"
    t.text    "authors"
    t.integer "source_id"
    t.integer "parent_id"
    t.string  "content_type"
    t.string  "filename"
    t.integer "size"
    t.integer "width"
    t.integer "height"
  end

  create_table "publications_treatments", :id => false, :force => true do |t|
    t.integer "treatment_id"
    t.integer "publication_id"
  end

  create_table "replicates", :id => false, :force => true do |t|
    t.string "replicate",   :limit => 50, :null => false
    t.string "description"
  end

  create_table "role_types", :force => true do |t|
    t.string "name"
  end

  create_table "roles", :force => true do |t|
    t.string  "name"
    t.integer "role_type_id"
    t.integer "seniority"
    t.boolean "show_in_overview",   :default => true
    t.boolean "show_in_detailview", :default => true
  end

  create_table "scribbles", :force => true do |t|
    t.integer "person_id"
    t.integer "protocol_id"
    t.integer "weight"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sources", :force => true do |t|
    t.string "title"
  end

  create_table "spatial_ref_sys", :id => false, :force => true do |t|
    t.integer "srid",                      :null => false
    t.string  "auth_name", :limit => 256
    t.integer "auth_srid"
    t.string  "srtext",    :limit => 2048
    t.string  "proj4text", :limit => 2048
  end

  create_table "species", :force => true do |t|
    t.string  "species"
    t.string  "genus"
    t.string  "family"
    t.string  "code"
    t.string  "common_name"
    t.string  "alternate_common_name"
    t.string  "attribution"
    t.boolean "woody"
  end

  create_table "studies", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.integer "weight"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.text    "synopsis"
    t.string  "url"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "themes", :force => true do |t|
    t.string  "name"
    t.integer "weight"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
  end

  create_table "treatments", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.integer "study_id"
    t.integer "weight"
  end

  create_table "units", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.boolean "in_eml",                     :default => false
    t.text    "definition"
    t.string  "human_name",  :limit => nil
  end

  add_index "units", ["name"], :name => "unit_names_key", :unique => true

  create_table "variates", :force => true do |t|
    t.string  "name"
    t.integer "datatable_id"
    t.integer "weight"
    t.text    "description"
    t.string  "missing_value_indicator"
    t.integer "unit_id"
    t.string  "measurement_scale"
    t.string  "data_type"
    t.float   "min_valid"
    t.float   "max_valid"
    t.string  "date_format"
    t.float   "precision"
    t.text    "query"
    t.integer "variate_theme_id"
  end

  create_table "venue_types", :force => true do |t|
    t.string "name"
    t.text   "description"
  end

end
