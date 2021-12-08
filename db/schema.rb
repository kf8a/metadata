# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_12_08_002722) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "fuzzystrmatch"
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "postgis_topology"
  enable_extension "uuid-ossp"

# Could not dump table "2_ed_lux_arbor_microplots" because of following StandardError
#   Unknown type 'geometry(PointZ,4326)' for column 'geom'

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "affiliations", id: :serial, force: :cascade do |t|
    t.integer "person_id"
    t.integer "role_id"
    t.integer "dataset_id"
    t.integer "seniority"
    t.string "title", limit: 255
    t.string "supervisor", limit: 255
    t.date "started_on"
    t.date "left_on"
    t.string "research_interest", limit: 255
    t.index ["dataset_id"], name: "index_affiliations_on_dataset_id"
    t.index ["person_id"], name: "index_affiliations_on_person_id"
    t.index ["role_id"], name: "index_affiliations_on_role_id"
  end

# Could not dump table "areas" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "areas_temporary" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "authors", id: :serial, force: :cascade do |t|
    t.string "sur_name", limit: 255
    t.string "given_name", limit: 255
    t.string "middle_name", limit: 255
    t.integer "seniority"
    t.integer "person_id"
    t.integer "citation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "suffix", limit: 255
    t.index ["citation_id"], name: "index_authors_on_citation_id"
    t.index ["person_id"], name: "index_authors_on_person_id"
  end

  create_table "barcodes", id: :serial, force: :cascade do |t|
    t.index ["id"], name: "barcodes_id_uindex", unique: true
  end

  create_table "citation_types", id: :serial, force: :cascade do |t|
    t.string "abbreviation", limit: 255
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "citations", id: :serial, force: :cascade do |t|
    t.text "title"
    t.text "abstract"
    t.date "pub_date"
    t.integer "pub_year"
    t.integer "citation_type_id"
    t.text "address"
    t.text "notes"
    t.string "publication", limit: 255
    t.string "start_page_number", limit: 255
    t.string "ending_page_number", limit: 255
    t.text "periodical_full_name"
    t.string "periodical_abbreviation", limit: 255
    t.string "volume", limit: 255
    t.string "issue", limit: 255
    t.string "city", limit: 255
    t.string "publisher", limit: 255
    t.string "secondary_title", limit: 255
    t.string "series_title", limit: 255
    t.string "isbn", limit: 255
    t.string "doi", limit: 255
    t.text "full_text"
    t.string "publisher_url", limit: 255
    t.integer "website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "pdf_file_name", limit: 255
    t.string "pdf_content_type", limit: 255
    t.integer "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.string "state", limit: 255
    t.boolean "open_access", default: false
    t.string "type", limit: 255
    t.boolean "has_lter_acknowledgement"
    t.string "annotation", limit: 255
    t.string "data_url"
    t.datetime "from_reporting_system_on"
    t.index ["citation_type_id"], name: "index_citations_on_citation_type_id"
    t.index ["website_id"], name: "index_citations_on_website_id"
  end

  create_table "citations_datatables", id: false, force: :cascade do |t|
    t.integer "citation_id"
    t.integer "datatable_id"
  end

  create_table "citations_treatments", id: false, force: :cascade do |t|
    t.integer "citation_id"
    t.integer "treatment_id"
  end

  create_table "collections", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "datatable_id"
    t.index ["datatable_id"], name: "index_collections_on_datatable_id"
  end

  create_table "columns", id: :serial, force: :cascade do |t|
    t.integer "datatable_id"
    t.integer "variate_id"
    t.integer "position"
    t.string "name", limit: 255
    t.index ["datatable_id"], name: "index_columns_on_datatable_id"
    t.index ["variate_id"], name: "index_columns_on_variate_id"
  end

  create_table "core_areas", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "core_areas_datatables", id: :serial, force: :cascade do |t|
    t.integer "core_area_id"
    t.integer "datatable_id"
  end

  create_table "data_contributions", id: :serial, force: :cascade do |t|
    t.integer "person_id"
    t.integer "datatable_id"
    t.integer "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "seniority"
    t.index ["datatable_id", "person_id", "role_id"], name: "data_contributions_uniq_idx", unique: true
  end

  create_table "data_usages", force: :cascade do |t|
    t.integer "dataset_id"
    t.integer "citation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "data_versions", id: :serial, force: :cascade do |t|
    t.integer "dataset_id"
    t.string "doi"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "datafiles", id: :serial, force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.string "original_data_file_name", limit: 255
    t.string "original_data_content_type", limit: 255
    t.integer "original_data_file_size"
    t.integer "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["person_id"], name: "index_datafiles_on_person_id"
  end

  create_table "dataset_dois", id: :serial, force: :cascade do |t|
    t.integer "dataset_id"
    t.string "doi"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "version"
  end

  create_table "dataset_files", id: :serial, force: :cascade do |t|
    t.text "name"
    t.integer "dataset_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "data_file_name", limit: 255
    t.string "data_content_type", limit: 255
    t.integer "data_file_size"
    t.datetime "data_updated_at"
  end

  create_table "datasets", id: :serial, force: :cascade do |t|
    t.string "dataset", limit: 255
    t.string "title", limit: 255
    t.text "abstract"
    t.string "old_keywords", limit: 255
    t.string "status", limit: 255
    t.date "initiated"
    t.date "completed"
    t.date "released"
    t.boolean "on_web", default: true
    t.integer "version", default: 1
    t.boolean "core_dataset", default: false
    t.integer "project_id"
    t.integer "metacat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sponsor_id"
    t.integer "website_id"
    t.boolean "pasta_ready", default: false
    t.date "data_end_date"
    t.boolean "cc0", default: false, null: false
    t.float "west_bounding_coordinate"
    t.float "east_bounding_coordinate"
    t.float "north_bounding_coordinate"
    t.float "south_bounding_coordinate"
    t.text "doi"
    t.index ["dataset"], name: "datasets_dataset_key", unique: true
    t.index ["metacat_id"], name: "index_datasets_on_metacat_id"
    t.index ["project_id"], name: "index_datasets_on_project_id"
    t.index ["sponsor_id"], name: "index_datasets_on_sponsor_id"
    t.index ["website_id"], name: "index_datasets_on_website_id"
  end

  create_table "datasets_studies", id: false, force: :cascade do |t|
    t.integer "dataset_id"
    t.integer "study_id"
    t.index ["dataset_id"], name: "index_datasets_studies_on_dataset_id"
    t.index ["study_id"], name: "index_datasets_studies_on_study_id"
  end

  create_table "datasets_themes", id: false, force: :cascade do |t|
    t.integer "theme_id"
    t.integer "dataset_id"
    t.index ["dataset_id"], name: "index_datasets_themes_on_dataset_id"
    t.index ["theme_id"], name: "index_datasets_themes_on_theme_id"
  end

  create_table "datatables", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "title", limit: 255
    t.text "comments"
    t.integer "dataset_id"
    t.string "data_url", limit: 255
    t.boolean "is_restricted"
    t.text "description"
    t.text "object"
    t.string "metadata_url", limit: 255
    t.boolean "is_sql"
    t.integer "update_frequency_days"
    t.date "last_updated_on"
    t.text "access_statement"
    t.integer "excerpt_limit"
    t.date "begin_date"
    t.date "end_date"
    t.boolean "on_web", default: true
    t.integer "theme_id"
    t.integer "core_area_id"
    t.integer "weight", default: 100
    t.integer "study_id"
    t.datetime "created_at"
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.boolean "is_secondary", default: false
    t.boolean "is_utf_8", default: false
    t.boolean "metadata_only", default: false
    t.text "summary_graph"
    t.integer "deprecated_in_favor_of"
    t.text "deprecation_notice"
    t.integer "number_of_released_records"
    t.text "scores"
    t.date "completed_on"
    t.text "workflow_state"
    t.string "csv_cache_file_name", limit: 255
    t.string "csv_cache_content_type", limit: 255
    t.integer "csv_cache_file_size"
    t.datetime "csv_cache_updated_at"
    t.integer "update_cache_days"
    t.integer "sponsor_id"
    t.text "connection_url"
    t.index ["core_area_id"], name: "index_datatables_on_core_area_id"
    t.index ["dataset_id"], name: "index_datatables_on_dataset_id"
    t.index ["name"], name: "datatables_name_key", unique: true
    t.index ["study_id"], name: "index_datatables_on_study_id"
    t.index ["theme_id"], name: "index_datatables_on_theme_id"
  end

  create_table "datatables_protocols", primary_key: ["datatable_id", "protocol_id"], force: :cascade do |t|
    t.integer "datatable_id", null: false
    t.integer "protocol_id", null: false
    t.index ["datatable_id"], name: "index_datatables_protocols_on_datatable_id"
    t.index ["protocol_id"], name: "index_datatables_protocols_on_protocol_id"
  end

  create_table "datatables_variates", id: :serial, force: :cascade do |t|
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.string "last_error", limit: 255
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "editors", id: :serial, force: :cascade do |t|
    t.string "sur_name", limit: 255
    t.string "given_name", limit: 255
    t.string "middle_name", limit: 255
    t.integer "seniority"
    t.integer "person_id"
    t.integer "citation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "suffix", limit: 255
  end

  create_table "eml_docs", id: :serial, force: :cascade do |t|
  end

# Could not dump table "farm_fields0" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

  create_table "invites", id: :serial, force: :cascade do |t|
    t.string "firstname", limit: 255
    t.string "lastname", limit: 255
    t.string "email", limit: 255
    t.string "invite_code", limit: 40
    t.datetime "invited_at"
    t.datetime "redeemed_at"
    t.boolean "glbrc_member"
    t.index ["id", "email"], name: "index_invites_on_id_and_email"
    t.index ["id", "invite_code"], name: "index_invites_on_id_and_invite_code"
  end

# Could not dump table "locations" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "ltar_sampling_locations" because of following StandardError
#   Unknown type 'geometry(Point,26916)' for column 'geom'

  create_table "measurement_scales", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "meeting_abstract_types", id: :serial, force: :cascade do |t|
    t.text "name"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meeting_abstracts", id: :serial, force: :cascade do |t|
    t.text "title"
    t.text "authors"
    t.text "abstract"
    t.integer "meeting_id"
    t.string "pdf_file_name", limit: 255
    t.string "pdf_content_type", limit: 255
    t.integer "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.text "author_affiliations"
    t.integer "meeting_abstract_type_id"
    t.datetime "updated_at"
    t.index ["meeting_id"], name: "index_meeting_abstracts_on_meeting_id"
  end

  create_table "meetings", id: :serial, force: :cascade do |t|
    t.date "date"
    t.string "title", limit: 255
    t.text "announcement"
    t.integer "venue_type_id"
    t.date "date_to"
    t.index ["venue_type_id"], name: "index_meetings_on_venue_type_id"
  end

  create_table "memberships", id: :serial, force: :cascade do |t|
    t.integer "sponsor_id"
    t.integer "user_id"
  end

  create_table "ownerships", id: :serial, force: :cascade do |t|
    t.integer "datatable_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["datatable_id"], name: "index_ownerships_on_datatable_id"
    t.index ["user_id"], name: "index_ownerships_on_user_id"
  end

  create_table "page_images", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.string "attribution", limit: 255
    t.integer "page_id"
    t.string "image_file_name", limit: 255
    t.string "image_content_type", limit: 255
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.index ["page_id"], name: "index_page_images_on_page_id"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.text "body"
    t.string "url", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.string "person", limit: 255
    t.string "sur_name", limit: 255
    t.string "given_name", limit: 255
    t.string "middle_name", limit: 255
    t.string "friendly_name", limit: 255
    t.string "title", limit: 255
    t.string "sub_organization", limit: 255
    t.string "organization", limit: 255
    t.string "street_address", limit: 255
    t.string "city", limit: 255
    t.string "locale", limit: 255
    t.string "country", limit: 255
    t.string "postal_code", limit: 255
    t.string "phone", limit: 255
    t.string "fax", limit: 255
    t.string "email", limit: 255
    t.string "url", limit: 255
    t.boolean "deceased"
    t.string "open_id", limit: 255
    t.boolean "is_postdoc"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.string "orcid_id"
    t.string "lno_name"
    t.integer "graduation_year"
    t.integer "thesis_id"
    t.text "lter_awards"
    t.boolean "lter_thesis", default: false
    t.text "thesis_url"
    t.string "thesis_type", limit: 3
    t.index ["sur_name", "given_name", "middle_name", "friendly_name"], name: "people_sur_name_given_name_middle_name_friendly_name_key", unique: true
  end

  create_table "permission_requests", id: :serial, force: :cascade do |t|
    t.integer "datatable_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["datatable_id"], name: "index_permission_requests_on_datatable_id"
    t.index ["user_id"], name: "index_permission_requests_on_user_id"
  end

  create_table "permissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "datatable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "owner_id"
    t.string "decision", limit: 255
    t.index ["datatable_id"], name: "index_permissions_on_datatable_id"
    t.index ["owner_id"], name: "index_permissions_on_owner_id"
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "person_projects", force: :cascade do |t|
    t.integer "person_id"
    t.integer "project_id"
    t.integer "role_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.text "abstract"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "funder_name"
    t.string "funder_identifier"
    t.string "award_number"
    t.string "award_url"
  end

  create_table "protocols", id: :integer, default: -> { "nextval('methocols_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "title", limit: 255
    t.integer "version_tag", default: 1
    t.date "in_use_from"
    t.date "in_use_to"
    t.text "description"
    t.text "abstract"
    t.text "body"
    t.integer "person_id"
    t.date "created_on"
    t.date "updated_on"
    t.text "change_summary"
    t.integer "dataset_id"
    t.boolean "active", default: true
    t.integer "deprecates"
    t.string "pdf_file_name", limit: 255
    t.string "pdf_content_type", limit: 255
    t.integer "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["dataset_id"], name: "index_protocols_on_dataset_id"
    t.index ["person_id"], name: "index_protocols_on_person_id"
  end

  create_table "protocols_sponsors", id: false, force: :cascade do |t|
    t.integer "protocol_id"
    t.integer "sponsor_id"
    t.index ["protocol_id"], name: "index_protocols_sponsors_on_protocol_id"
    t.index ["sponsor_id"], name: "index_protocols_sponsors_on_sponsor_id"
  end

  create_table "protocols_websites", id: false, force: :cascade do |t|
    t.integer "protocol_id"
    t.integer "website_id"
    t.index ["protocol_id"], name: "index_protocols_websites_on_protocol_id"
    t.index ["website_id"], name: "index_protocols_websites_on_website_id"
  end

  create_table "publication_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "publications", id: :serial, force: :cascade do |t|
    t.integer "publication_type_id"
    t.text "citation"
    t.text "abstract"
    t.integer "year"
    t.string "file_url", limit: 255
    t.text "title"
    t.text "authors"
    t.integer "source_id"
    t.integer "parent_id"
    t.string "content_type", limit: 255
    t.string "filename", limit: 255
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.boolean "deprecated"
    t.index ["parent_id"], name: "index_publications_on_parent_id"
    t.index ["publication_type_id"], name: "index_publications_on_publication_type_id"
    t.index ["source_id"], name: "index_publications_on_source_id"
  end

  create_table "publications_treatments", id: false, force: :cascade do |t|
    t.integer "treatment_id"
    t.integer "publication_id"
    t.index ["publication_id"], name: "index_publications_treatments_on_publication_id"
    t.index ["treatment_id"], name: "index_publications_treatments_on_treatment_id"
  end

  create_table "replicates", id: false, force: :cascade do |t|
    t.string "replicate", limit: 50, null: false
    t.string "description", limit: 255
  end

  create_table "replication_check", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.datetime "value"
  end

  create_table "role_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "role_type_id"
    t.integer "seniority"
    t.boolean "show_in_overview", default: true
    t.boolean "show_in_detailview", default: true
    t.index ["role_type_id"], name: "index_roles_on_role_type_id"
  end

  create_table "scribbles", id: :serial, force: :cascade do |t|
    t.integer "person_id"
    t.integer "protocol_id"
    t.integer "weight"
    t.index ["person_id"], name: "index_scribbles_on_person_id"
    t.index ["protocol_id"], name: "index_scribbles_on_protocol_id"
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", limit: 255
    t.text "data"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "sites", id: :serial, force: :cascade do |t|
    t.string "sitename", limit: 255, null: false
    t.text "description"
    t.date "start_date"
    t.date "end_date"
    t.string "sitecode", limit: 255
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "slugs", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "sluggable_id"
    t.integer "sequence", default: 1, null: false
    t.string "sluggable_type", limit: 40
    t.string "scope", limit: 255
    t.datetime "created_at"
    t.index ["name", "sluggable_type", "sequence", "scope"], name: "index_slugs_on_n_s_s_and_s", unique: true
    t.index ["sluggable_id"], name: "index_slugs_on_sluggable_id"
  end

  create_table "sources", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
  end

  create_table "spatial_ref_sys", primary_key: "srid", id: :integer, default: nil, force: :cascade do |t|
    t.string "auth_name", limit: 256
    t.integer "auth_srid"
    t.string "srtext", limit: 2048
    t.string "proj4text", limit: 2048
    t.check_constraint "(srid > 0) AND (srid <= 998999)", name: "spatial_ref_sys_srid_check"
  end

  create_table "sponsors", id: :serial, comment: "Control the accessibility of data", force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "data_restricted", default: false
    t.text "data_use_statement"
    t.string "terms_of_use_url"
  end

  create_table "studies", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.integer "weight"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.text "synopsis"
    t.string "url", limit: 255
    t.string "code", limit: 255
    t.text "warning"
    t.text "source"
    t.text "old_names"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["code"], name: "studies_code_uindex", unique: true
    t.index ["parent_id"], name: "index_studies_on_parent_id"
  end

  create_table "study_urls", id: :serial, force: :cascade do |t|
    t.integer "website_id"
    t.integer "study_id"
    t.string "url", limit: 255
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.integer "tagger_id"
    t.string "tagger_type", limit: 255
    t.string "taggable_type", limit: 255
    t.string "context", limit: 255
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "templates", id: :serial, force: :cascade do |t|
    t.integer "website_id"
    t.string "controller", limit: 255
    t.string "action", limit: 255
    t.text "layout"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["website_id"], name: "index_templates_on_website_id"
  end

  create_table "themes", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "weight"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["name", "parent_id"], name: "themes_name_parent_id_uindex", unique: true
    t.index ["parent_id"], name: "index_themes_on_parent_id"
  end

  create_table "treatments", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.integer "study_id"
    t.integer "weight"
    t.text "deprecated_names"
    t.text "management"
    t.text "dominant_plants"
    t.date "start_date"
    t.date "end_date"
    t.boolean "use_in_citations", default: true
    t.index ["study_id"], name: "index_treatments_on_study_id"
  end

  create_table "units", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.boolean "in_eml", default: false
    t.text "definition"
    t.integer "deprecated_in_favor_of"
    t.string "unit_type", limit: 255
    t.string "parent_si", limit: 255
    t.float "multiplier_to_si"
    t.string "abbreviation"
    t.string "label", limit: 255
    t.float "offset_to_si"
    t.index ["name"], name: "unit_names_key", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255
    t.string "encrypted_password", limit: 128
    t.string "salt", limit: 128
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128
    t.boolean "email_confirmed", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "identity_url", limit: 255
    t.string "role", limit: 255
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email"
    t.index ["email"], name: "users_email_key", unique: true
    t.index ["id", "confirmation_token"], name: "index_users_on_id_and_confirmation_token"
    t.index ["identity_url"], name: "index_users_on_identity_url", unique: true
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  create_table "variates", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "datatable_id"
    t.integer "weight"
    t.text "description"
    t.string "missing_value_indicator", limit: 255
    t.integer "unit_id"
    t.string "measurement_scale", limit: 255
    t.string "data_type", limit: 255
    t.float "min_valid"
    t.float "max_valid"
    t.string "date_format", limit: 255
    t.float "precision"
    t.text "query"
    t.integer "variate_theme_id"
    t.index ["datatable_id"], name: "index_variates_on_datatable_id"
    t.index ["unit_id"], name: "index_variates_on_unit_id"
    t.index ["variate_theme_id"], name: "index_variates_on_variate_theme_id"
  end

  create_table "venue_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.integer "versioned_id"
    t.string "versioned_type", limit: 255
    t.integer "user_id"
    t.string "user_type", limit: 255
    t.string "user_name", limit: 255
    t.text "modifications"
    t.integer "number"
    t.integer "reverted_from"
    t.string "tag", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["created_at"], name: "index_versions_on_created_at"
    t.index ["number"], name: "index_versions_on_number"
    t.index ["tag"], name: "index_versions_on_tag"
    t.index ["user_id", "user_type"], name: "index_versions_on_user_id_and_user_type"
    t.index ["user_name"], name: "index_versions_on_user_name"
    t.index ["versioned_id", "versioned_type"], name: "index_versions_on_versioned_id_and_versioned_type"
  end

  create_table "visualizations", id: :serial, force: :cascade do |t|
    t.integer "datatable_id"
    t.string "title", limit: 255
    t.text "body"
    t.text "query"
    t.string "graph_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "x_axis_label", limit: 255
    t.string "y_axis_label", limit: 255
    t.integer "weight"
  end

  create_table "websites", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "data_catalog_intro"
    t.text "url"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "affiliations", "people", name: "affiliations_person_id_fkey"
  add_foreign_key "affiliations", "roles", name: "affiliations_role_id_fkey1"
  add_foreign_key "authors", "citations", name: "authors_citation_id_fk"
  add_foreign_key "authors", "citations", name: "authors_citation_id_fkey"
  add_foreign_key "dataset_dois", "datasets", name: "dataset_dois_datasets_id_fk"
  add_foreign_key "datasets", "projects", name: "datasets_projects_id_fk"
  add_foreign_key "datasets", "sponsors", name: "sponsorsdatasets___fk"
  add_foreign_key "datatables", "datasets", name: "datatables_dataset_id_fkey", on_update: :restrict, on_delete: :restrict
  add_foreign_key "editors", "citations", name: "editors_citation_id_fk"
  add_foreign_key "editors", "citations", name: "editors_citation_id_fkey"
  add_foreign_key "variates", "datatables", name: "variates_datatable_id_fkey"
  add_foreign_key "variates", "units", name: "variates_unit_id_fkey"
end
