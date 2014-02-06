# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140206152903) do

  create_table "affiliations", :force => true do |t|
    t.integer "person_id"
    t.integer "role_id"
    t.integer "dataset_id"
    t.integer "seniority"
    t.string  "title"
    t.string  "supervisor"
    t.date    "started_on"
    t.date    "left_on"
    t.string  "research_interest"
  end

  add_index "affiliations", ["dataset_id"], :name => "index_affiliations_on_dataset_id"
  add_index "affiliations", ["person_id"], :name => "index_affiliations_on_person_id"
  add_index "affiliations", ["role_id"], :name => "index_affiliations_on_role_id"

# Could not dump table "areas" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "areas_temporary" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "authors", :force => true do |t|
    t.string   "sur_name"
    t.string   "given_name"
    t.string   "middle_name"
    t.integer  "seniority"
    t.integer  "person_id"
    t.integer  "citation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "suffix"
  end

  add_index "authors", ["citation_id"], :name => "index_authors_on_citation_id"
  add_index "authors", ["person_id"], :name => "index_authors_on_person_id"

  create_table "citation_types", :force => true do |t|
    t.string   "abbreviation"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "citations", :force => true do |t|
    t.text     "title"
    t.text     "abstract"
    t.date     "pub_date"
    t.integer  "pub_year"
    t.integer  "citation_type_id"
    t.text     "address"
    t.text     "notes"
    t.string   "publication"
    t.string   "start_page_number"
    t.string   "ending_page_number"
    t.text     "periodical_full_name"
    t.string   "periodical_abbreviation"
    t.string   "volume"
    t.string   "issue"
    t.string   "city"
    t.string   "publisher"
    t.string   "secondary_title"
    t.string   "series_title"
    t.string   "isbn"
    t.string   "doi"
    t.text     "full_text"
    t.string   "publisher_url"
    t.integer  "website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pdf_file_name"
    t.string   "pdf_content_type"
    t.integer  "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.string   "state"
    t.boolean  "open_access",             :default => false
    t.string   "type"
  end

  add_index "citations", ["citation_type_id"], :name => "index_citations_on_citation_type_id"
  add_index "citations", ["website_id"], :name => "index_citations_on_website_id"

  create_table "citations_datatables", :id => false, :force => true do |t|
    t.integer "citation_id"
    t.integer "datatable_id"
  end

  create_table "citations_treatments", :id => false, :force => true do |t|
    t.integer "citation_id"
    t.integer "treatment_id"
  end

  create_table "collections", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "datatable_id"
  end

  add_index "collections", ["datatable_id"], :name => "index_collections_on_datatable_id"

  create_table "columns", :force => true do |t|
    t.integer "datatable_id"
    t.integer "variate_id"
    t.integer "position"
    t.string  "name"
  end

  add_index "columns", ["datatable_id"], :name => "index_columns_on_datatable_id"
  add_index "columns", ["variate_id"], :name => "index_columns_on_variate_id"

  create_table "core_areas", :force => true do |t|
    t.string "name"
  end

  create_table "core_areas_datatables", :force => true do |t|
    t.integer "core_area_id"
    t.integer "datatable_id"
  end

  create_table "data_contributions", :force => true do |t|
    t.integer  "person_id"
    t.integer  "datatable_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seniority"
  end

  add_index "data_contributions", ["datatable_id", "person_id", "role_id"], :name => "data_contributions_uniq_idx", :unique => true

  create_table "datafiles", :force => true do |t|
    t.text     "title"
    t.text     "description"
    t.string   "original_data_file_name"
    t.string   "original_data_content_type"
    t.integer  "original_data_file_size"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "datafiles", ["person_id"], :name => "index_datafiles_on_person_id"

  create_table "dataset_files", :force => true do |t|
    t.text     "name"
    t.integer  "dataset_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
  end

  create_table "datasets", :force => true do |t|
    t.string   "dataset"
    t.string   "title"
    t.text     "abstract"
    t.string   "old_keywords"
    t.string   "status"
    t.date     "initiated"
    t.date     "completed"
    t.date     "released"
    t.boolean  "on_web",        :default => true
    t.integer  "version",       :default => 1
    t.boolean  "core_dataset",  :default => false
    t.integer  "project_id"
    t.integer  "metacat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sponsor_id"
    t.integer  "website_id"
    t.boolean  "pasta_ready",   :default => false
    t.date     "data_end_date"
  end

  add_index "datasets", ["dataset"], :name => "datasets_dataset_key", :unique => true
  add_index "datasets", ["metacat_id"], :name => "index_datasets_on_metacat_id"
  add_index "datasets", ["project_id"], :name => "index_datasets_on_project_id"
  add_index "datasets", ["sponsor_id"], :name => "index_datasets_on_sponsor_id"
  add_index "datasets", ["website_id"], :name => "index_datasets_on_website_id"

  create_table "datasets_studies", :id => false, :force => true do |t|
    t.integer "dataset_id"
    t.integer "study_id"
  end

  add_index "datasets_studies", ["dataset_id"], :name => "index_datasets_studies_on_dataset_id"
  add_index "datasets_studies", ["study_id"], :name => "index_datasets_studies_on_study_id"

  create_table "datasets_themes", :id => false, :force => true do |t|
    t.integer "theme_id"
    t.integer "dataset_id"
  end

  add_index "datasets_themes", ["dataset_id"], :name => "index_datasets_themes_on_dataset_id"
  add_index "datasets_themes", ["theme_id"], :name => "index_datasets_themes_on_theme_id"

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
    t.boolean  "on_web",                     :default => true
    t.integer  "theme_id"
    t.integer  "core_area_id"
    t.integer  "weight",                     :default => 100
    t.integer  "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_secondary",               :default => false
    t.boolean  "is_utf_8",                   :default => false
    t.boolean  "metadata_only",              :default => false
    t.text     "summary_graph"
    t.integer  "deprecated_in_fovor_of"
    t.text     "deprecation_notice"
    t.integer  "number_of_released_records"
    t.text     "scores"
    t.date     "completed_on"
    t.text     "workflow_state"
    t.string   "csv_cache_file_name"
    t.string   "csv_cache_content_type"
    t.integer  "csv_cache_file_size"
    t.datetime "csv_cache_updated_at"
  end

  add_index "datatables", ["core_area_id"], :name => "index_datatables_on_core_area_id"
  add_index "datatables", ["dataset_id"], :name => "index_datatables_on_dataset_id"
  add_index "datatables", ["name"], :name => "datatables_name_key", :unique => true
  add_index "datatables", ["study_id"], :name => "index_datatables_on_study_id"
  add_index "datatables", ["theme_id"], :name => "index_datatables_on_theme_id"

  create_table "datatables_protocols", :id => false, :force => true do |t|
    t.integer "datatable_id", :null => false
    t.integer "protocol_id",  :null => false
  end

  add_index "datatables_protocols", ["datatable_id"], :name => "index_datatables_protocols_on_datatable_id"
  add_index "datatables_protocols", ["protocol_id"], :name => "index_datatables_protocols_on_protocol_id"

  create_table "datatables_variates", :force => true do |t|
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "editors", :force => true do |t|
    t.string   "sur_name"
    t.string   "given_name"
    t.string   "middle_name"
    t.integer  "seniority"
    t.integer  "person_id"
    t.integer  "citation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "suffix"
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

  create_table "glbrc_scaleup", :id => false, :force => true do |t|
  end

  create_table "invites", :force => true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "invite_code",  :limit => 40
    t.datetime "invited_at"
    t.datetime "redeemed_at"
    t.boolean  "glbrc_member"
  end

  add_index "invites", ["id", "email"], :name => "index_invites_on_id_and_email"
  add_index "invites", ["id", "invite_code"], :name => "index_invites_on_id_and_invite_code"

  create_table "kbs021_base_cache", :id => false, :force => true do |t|
    t.float   "year"
    t.string  "campaign",         :limit => nil
    t.date    "sample_date"
    t.string  "treatment",        :limit => nil
    t.string  "replicate",        :limit => nil
    t.boolean "release_nitrate"
    t.boolean "release_ammonium"
    t.float   "avgofno3ppm"
    t.float   "avgofnh4ppm"
    t.decimal "m"
    t.decimal "d"
    t.decimal "v"
  end

# Could not dump table "locations" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "log_hiresyieldmanagement", :id => false, :force => true do |t|
    t.date    "obsdate"
    t.integer "obsnumber"
    t.string  "author"
    t.text    "observation"
  end

  create_table "measurement_scales", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "meeting_abstracts", :force => true do |t|
    t.text     "title"
    t.text     "authors"
    t.text     "abstract"
    t.integer  "meeting_id"
    t.string   "pdf_file_name"
    t.string   "pdf_content_type"
    t.integer  "pdf_file_size"
    t.datetime "pdf_updated_at"
  end

  add_index "meeting_abstracts", ["meeting_id"], :name => "index_meeting_abstracts_on_meeting_id"

  create_table "meetings", :force => true do |t|
    t.date    "date"
    t.string  "title"
    t.text    "announcement"
    t.integer "venue_type_id"
    t.date    "date_to"
  end

  add_index "meetings", ["venue_type_id"], :name => "index_meetings_on_venue_type_id"

  create_table "memberships", :force => true do |t|
    t.integer "sponsor_id"
    t.integer "user_id"
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

  create_table "ownerships", :force => true do |t|
    t.integer  "datatable_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ownerships", ["datatable_id"], :name => "index_ownerships_on_datatable_id"
  add_index "ownerships", ["user_id"], :name => "index_ownerships_on_user_id"

  create_table "page_images", :force => true do |t|
    t.string   "title"
    t.string   "attribution"
    t.integer  "page_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "page_images", ["page_id"], :name => "index_page_images_on_page_id"

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.boolean "is_postdoc"
  end

  create_table "permission_requests", :force => true do |t|
    t.integer  "datatable_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permission_requests", ["datatable_id"], :name => "index_permission_requests_on_datatable_id"
  add_index "permission_requests", ["user_id"], :name => "index_permission_requests_on_user_id"

  create_table "permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "datatable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "decision"
  end

  add_index "permissions", ["datatable_id"], :name => "index_permissions_on_datatable_id"
  add_index "permissions", ["owner_id"], :name => "index_permissions_on_owner_id"
  add_index "permissions", ["user_id"], :name => "index_permissions_on_user_id"

  create_table "projects", :force => true do |t|
    t.string   "title"
    t.text     "abstract"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "protocols", :force => true do |t|
    t.string  "name"
    t.string  "title"
    t.integer "version_tag",    :default => 1
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
    t.integer "deprecates"
  end

  add_index "protocols", ["dataset_id"], :name => "index_protocols_on_dataset_id"
  add_index "protocols", ["person_id"], :name => "index_protocols_on_person_id"

  create_table "protocols_sponsors", :id => false, :force => true do |t|
    t.integer "protocol_id"
    t.integer "sponsor_id"
  end

  add_index "protocols_sponsors", ["protocol_id"], :name => "index_protocols_sponsors_on_protocol_id"
  add_index "protocols_sponsors", ["sponsor_id"], :name => "index_protocols_sponsors_on_sponsor_id"

  create_table "protocols_websites", :id => false, :force => true do |t|
    t.integer "protocol_id"
    t.integer "website_id"
  end

  add_index "protocols_websites", ["protocol_id"], :name => "index_protocols_websites_on_protocol_id"
  add_index "protocols_websites", ["website_id"], :name => "index_protocols_websites_on_website_id"

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
    t.boolean "deprecated"
  end

  add_index "publications", ["parent_id"], :name => "index_publications_on_parent_id"
  add_index "publications", ["publication_type_id"], :name => "index_publications_on_publication_type_id"
  add_index "publications", ["source_id"], :name => "index_publications_on_source_id"

  create_table "publications_treatments", :id => false, :force => true do |t|
    t.integer "treatment_id"
    t.integer "publication_id"
  end

  add_index "publications_treatments", ["publication_id"], :name => "index_publications_treatments_on_publication_id"
  add_index "publications_treatments", ["treatment_id"], :name => "index_publications_treatments_on_treatment_id"

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

  add_index "roles", ["role_type_id"], :name => "index_roles_on_role_type_id"

  create_table "scribbles", :force => true do |t|
    t.integer "person_id"
    t.integer "protocol_id"
    t.integer "weight"
  end

  add_index "scribbles", ["person_id"], :name => "index_scribbles_on_person_id"
  add_index "scribbles", ["protocol_id"], :name => "index_scribbles_on_protocol_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

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

  create_table "sponsors", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "data_restricted",    :default => false
    t.text     "data_use_statement"
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
    t.string  "code"
    t.text    "warning"
    t.text    "source"
    t.text    "old_names"
  end

  add_index "studies", ["parent_id"], :name => "index_studies_on_parent_id"

  create_table "study_urls", :force => true do |t|
    t.integer "website_id"
    t.integer "study_id"
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
  add_index "taggings", ["tagger_id"], :name => "index_taggings_on_tagger_id"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "templates", :force => true do |t|
    t.integer  "website_id"
    t.string   "controller"
    t.string   "action"
    t.text     "layout"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "templates", ["website_id"], :name => "index_templates_on_website_id"

  create_table "themes", :force => true do |t|
    t.string  "name"
    t.integer "weight"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
  end

  add_index "themes", ["parent_id"], :name => "index_themes_on_parent_id"

  create_table "treatments", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.integer "study_id"
    t.integer "weight"
    t.text    "deprecated_names"
    t.text    "management"
    t.text    "dominant_plants"
    t.date    "start_date"
    t.date    "end_date"
    t.boolean "use_in_citations", :default => true
  end

  add_index "treatments", ["study_id"], :name => "index_treatments_on_study_id"

  create_table "units", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.boolean "in_eml",                                :default => false
    t.text    "definition"
    t.integer "deprecated_in_favor_of"
    t.string  "unit_type"
    t.string  "parent_si"
    t.float   "multiplier_to_si"
    t.string  "abbreviation",           :limit => nil
    t.string  "label"
    t.float   "offset_to_si"
  end

  add_index "units", ["name"], :name => "unit_names_key", :unique => true

  create_table "uploads", :force => true do |t|
    t.string   "title"
    t.string   "owners"
    t.text     "abstract"
    t.binary   "file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password", :limit => 128
    t.string   "salt",               :limit => 128
    t.string   "confirmation_token", :limit => 128
    t.string   "remember_token",     :limit => 128
    t.boolean  "email_confirmed",                   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identity_url"
    t.string   "role"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["id", "confirmation_token"], :name => "index_users_on_id_and_confirmation_token"
  add_index "users", ["identity_url"], :name => "index_users_on_identity_url", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

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

  add_index "variates", ["datatable_id"], :name => "index_variates_on_datatable_id"
  add_index "variates", ["unit_id"], :name => "index_variates_on_unit_id"
  add_index "variates", ["variate_theme_id"], :name => "index_variates_on_variate_theme_id"

  create_table "venue_types", :force => true do |t|
    t.string "name"
    t.text   "description"
  end

  create_table "versions", :force => true do |t|
    t.integer  "versioned_id"
    t.string   "versioned_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "user_name"
    t.text     "modifications"
    t.integer  "number"
    t.integer  "reverted_from"
    t.string   "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["number"], :name => "index_versions_on_number"
  add_index "versions", ["tag"], :name => "index_versions_on_tag"
  add_index "versions", ["user_id", "user_type"], :name => "index_versions_on_user_id_and_user_type"
  add_index "versions", ["user_name"], :name => "index_versions_on_user_name"
  add_index "versions", ["versioned_id", "versioned_type"], :name => "index_versions_on_versioned_id_and_versioned_type"

  create_table "visualizations", :force => true do |t|
    t.integer  "datatable_id"
    t.string   "title"
    t.text     "body"
    t.text     "query"
    t.string   "graph_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "x_axis_label"
    t.string   "y_axis_label"
    t.integer  "weight"
  end

  create_table "websites", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "data_catalog_intro"
    t.text     "url"
  end

  add_foreign_key "affiliations", "people", :name => "affiliations_person_id_fkey"
  add_foreign_key "affiliations", "roles", :name => "affiliations_role_id_fkey1"

  add_foreign_key "authors", "citations", :name => "authors_citation_id_fk"
  add_foreign_key "authors", "citations", :name => "authors_citation_id_fkey"

  add_foreign_key "datatables", "datasets", :name => "datatables_dataset_id_fkey", :dependent => :restrict

  add_foreign_key "editors", "citations", :name => "editors_citation_id_fk"
  add_foreign_key "editors", "citations", :name => "editors_citation_id_fkey"

  add_foreign_key "variates", "units", :name => "variates_unit_id_fkey"

end
