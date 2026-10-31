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

ActiveRecord::Schema[8.1].define(version: 2026_11_01_000000) do
  create_schema "topology"

  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "citext"
  enable_extension "fuzzystrmatch"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"
  enable_extension "postgis"
  enable_extension "postgis_raster"
  enable_extension "postgres_fdw"
  enable_extension "topology.postgis_topology"
  enable_extension "uuid-ossp"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "public.main_or_microplot", ["fertilized microplot", "main", "microplot", "nitrogen microplot", "rainout", "restored prairie", "stover microplot", "stover non removal microplot", "unfertilized microplot", "fertilized subplot", "unfertilized subplot", "stover non-removal subplot"]
  create_enum "public.oban_job_state", ["available", "scheduled", "executing", "retryable", "completed", "discarded", "cancelled"]
  create_enum "public.planned_or_associated_biodiversity", ["planned", "associated"]

# Could not dump table "2_ed_lux_arbor_microplots" because of following StandardError
#   Unknown type 'geometry(PointZ,4326)' for column 'geom'


# Could not dump table "LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy_a_v2025" because of following StandardError
#   Unknown type 'geometry(MultiPolygonZM,3857)' for column 'geom'


  create_table "public.Source", id: false, force: :cascade do |t|
    t.float "F1"
    t.float "F2"
  end

  create_table "public.active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "public.active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "public.active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "public.affiliations", id: :serial, force: :cascade do |t|
    t.integer "person_id", null: false
    t.integer "role_id", null: false
    t.integer "dataset_id"
    t.integer "seniority"
    t.string "title", limit: 255
    t.string "supervisor", limit: 255
    t.date "started_on"
    t.date "left_on"
    t.string "research_interest", limit: 255
    t.string "lno_record_id"
    t.timestamptz "created_at", default: -> { "now()" }
    t.timestamptz "updated_at", default: -> { "now()" }
    t.index ["dataset_id"], name: "index_affiliations_on_dataset_id"
    t.index ["person_id"], name: "index_affiliations_on_person_id"
    t.index ["role_id"], name: "index_affiliations_on_role_id"
  end

  create_table "public.analysis_labs", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.text "name", null: false
  end

# Could not dump table "areas" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'


# Could not dump table "areas_temporary" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'


  create_table "public.authors", id: :serial, force: :cascade do |t|
    t.string "sur_name", limit: 255
    t.string "given_name", limit: 255
    t.string "middle_name", limit: 255
    t.integer "seniority"
    t.integer "person_id"
    t.integer "citation_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "suffix", limit: 255
    t.integer "orchid"
    t.index ["citation_id"], name: "index_authors_on_citation_id"
    t.index ["person_id"], name: "index_authors_on_person_id"
  end

  create_table "public.barcode", id: { type: :string, limit: 24, default: -> { "nanoid(13)" } }, force: :cascade do |t|
    t.text "table_destiny"
  end

  create_table "public.chambers", id: :integer, default: -> { "nextval('gas_chambers_id_seq'::regclass)" }, force: :cascade do |t|
    t.timestamptz "inserted_at", default: -> { "now()" }, null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.string "barcode", limit: 21, null: false
    t.index ["barcode"], name: "gas_chambers_index_2", unique: true, order: :desc
  end

  create_table "public.citation_types", id: :serial, force: :cascade do |t|
    t.string "abbreviation", limit: 255
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "public.citations", id: :serial, force: :cascade do |t|
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
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "pdf_file_name", limit: 255
    t.string "pdf_content_type", limit: 255
    t.integer "pdf_file_size"
    t.datetime "pdf_updated_at", precision: nil
    t.string "state", limit: 255
    t.boolean "open_access", default: false
    t.string "type", limit: 255
    t.boolean "has_lter_acknowledgement"
    t.string "annotation", limit: 255
    t.string "data_url"
    t.timestamptz "from_reporting_system_on"
    t.integer "is_referenced_by_count", default: 0
    t.text "abstract_backup"
    t.datetime "inserted_at", precision: nil
    t.index ["citation_type_id"], name: "index_citations_on_citation_type_id"
    t.index ["website_id"], name: "index_citations_on_website_id"
  end

  create_table "public.citations_datatables", id: false, force: :cascade do |t|
    t.integer "citation_id"
    t.integer "datatable_id"
  end

  create_table "public.citations_treatments", id: false, force: :cascade do |t|
    t.integer "citation_id"
    t.integer "treatment_id"
  end

  create_table "public.collections", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "datatable_id"
    t.index ["datatable_id"], name: "index_collections_on_datatable_id"
  end

  create_table "public.columns", id: :serial, force: :cascade do |t|
    t.integer "datatable_id"
    t.integer "variate_id"
    t.integer "position"
    t.string "name", limit: 255
    t.index ["datatable_id"], name: "index_columns_on_datatable_id"
    t.index ["variate_id"], name: "index_columns_on_variate_id"
  end

  create_table "public.core_areas", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "public.core_areas_datatables", id: :serial, force: :cascade do |t|
    t.integer "core_area_id"
    t.integer "datatable_id"
  end

  create_table "public.data_contributions", id: :serial, force: :cascade do |t|
    t.integer "person_id"
    t.integer "datatable_id"
    t.integer "role_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "seniority"
    t.index ["datatable_id", "person_id", "role_id"], name: "data_contributions_uniq_idx", unique: true
  end

  create_table "public.data_usages", force: :cascade do |t|
    t.integer "dataset_id"
    t.integer "citation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "public.data_versions", id: :serial, force: :cascade do |t|
    t.integer "dataset_id"
    t.string "doi"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "public.datafiles", id: :serial, force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.string "original_data_file_name", limit: 255
    t.string "original_data_content_type", limit: 255
    t.integer "original_data_file_size"
    t.integer "person_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["person_id"], name: "index_datafiles_on_person_id"
  end

  create_table "public.dataset_dois", id: :serial, force: :cascade do |t|
    t.integer "dataset_id", null: false
    t.string "doi", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "version", null: false
    t.bigint "nsf_par_id"
  end

  create_table "public.dataset_files", id: :serial, force: :cascade do |t|
    t.text "name"
    t.integer "dataset_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "data_file_name", limit: 255
    t.string "data_content_type", limit: 255
    t.integer "data_file_size"
    t.datetime "data_updated_at", precision: nil
  end

  create_table "public.datasets", id: :serial, force: :cascade do |t|
    t.string "dataset", limit: 255
    t.string "title", limit: 255
    t.text "abstract", null: false
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
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.integer "sponsor_id", default: 1
    t.integer "website_id", default: 1
    t.boolean "pasta_ready", default: false
    t.date "data_end_date"
    t.boolean "cc0", default: false, null: false
    t.float "west_bounding_coordinate"
    t.float "east_bounding_coordinate"
    t.float "north_bounding_coordinate"
    t.float "south_bounding_coordinate"
    t.text "doi"
    t.text "abstract_backup"
    t.string "licence", limit: 25
    t.index ["metacat_id"], name: "index_datasets_on_metacat_id"
    t.index ["project_id"], name: "index_datasets_on_project_id"
    t.index ["sponsor_id"], name: "index_datasets_on_sponsor_id"
    t.index ["website_id"], name: "index_datasets_on_website_id"
    t.unique_constraint ["dataset"], name: "datasets_dataset_key"
  end

  create_table "public.datasets_studies", id: false, force: :cascade do |t|
    t.integer "dataset_id"
    t.integer "study_id"
    t.index ["dataset_id"], name: "index_datasets_studies_on_dataset_id"
    t.index ["study_id"], name: "index_datasets_studies_on_study_id"
  end

  create_table "public.datasets_themes", id: false, force: :cascade do |t|
    t.integer "theme_id"
    t.integer "dataset_id"
    t.index ["dataset_id"], name: "index_datasets_themes_on_dataset_id"
    t.index ["theme_id"], name: "index_datasets_themes_on_theme_id"
  end

  create_table "public.datatables", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "title", limit: 255
    t.text "comments"
    t.integer "dataset_id", null: false
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
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
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
    t.datetime "csv_cache_updated_at", precision: nil
    t.integer "update_cache_days"
    t.integer "sponsor_id"
    t.text "connection_url"
    t.text "description_backup"
    t.index ["core_area_id"], name: "index_datatables_on_core_area_id"
    t.index ["dataset_id"], name: "index_datatables_on_dataset_id"
    t.index ["study_id"], name: "index_datatables_on_study_id"
    t.index ["theme_id"], name: "index_datatables_on_theme_id"
    t.unique_constraint ["name"], nulls_not_distinct: true, name: "datatables_name_key"
  end

  create_table "public.datatables_dois", id: :serial, force: :cascade do |t|
    t.integer "datatable_id", null: false
    t.text "doi", null: false
    t.timestamptz "inserted_at", default: -> { "now()" }
    t.timestamptz "updated_at", default: -> { "now()" }
    t.text "paper_doi"
    t.integer "data_begin_year"
    t.integer "data_end_year"
    t.text "treatments"
  end

  create_table "public.datatables_protocols", primary_key: ["datatable_id", "protocol_id"], force: :cascade do |t|
    t.integer "datatable_id", null: false
    t.integer "protocol_id", null: false
    t.index ["datatable_id"], name: "index_datatables_protocols_on_datatable_id"
    t.index ["protocol_id"], name: "index_datatables_protocols_on_protocol_id"
  end

  create_table "public.datatables_variates", id: :serial, force: :cascade do |t|
  end

  create_table "public.delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.string "last_error", limit: 255
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "public.devise_invitations", force: :cascade do |t|
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.datetime "superseded_at"
    t.string "superseded_reason"
    t.datetime "revoked_at"
    t.datetime "resource_created_at"
    t.json "invite_key", default: {}, null: false
    t.string "invite_key_digest", null: false
    t.string "invitable_type"
    t.bigint "invitable_id"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invitable_type", "invitable_id"], name: "index_devise_invitations_on_invitable"
    t.index ["invitable_type", "invite_key_digest"], name: "index_devise_invitations_on_type_and_invite_key"
    t.index ["invitation_token"], name: "index_devise_invitations_on_invitation_token", unique: true
    t.index ["invited_by_type", "invited_by_id"], name: "index_devise_invitations_on_invited_by"
  end

  create_table "public.editors", id: :serial, force: :cascade do |t|
    t.string "sur_name", limit: 255
    t.string "given_name", limit: 255
    t.string "middle_name", limit: 255
    t.integer "seniority"
    t.integer "person_id"
    t.integer "citation_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "suffix", limit: 255
  end

  create_table "public.eml_docs", id: :serial, force: :cascade do |t|
  end

  create_table "public.enumerated_values", force: :cascade do |t|
    t.bigint "variate_id", null: false
    t.string "code"
    t.string "description", null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["variate_id"], name: "index_enumerated_values_on_variate_id"
  end

# Could not dump table "farm_fields0" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'


  create_table "public.fertilization", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.integer "dataset_id"
    t.date "fertilization_date"
    t.integer "fertilization_id"
    t.string "treatment"
    t.string "replicate"
    t.string "fertilization_date_description"
  end

  create_table "public.invites", id: :serial, force: :cascade do |t|
    t.string "firstname", limit: 255
    t.string "lastname", limit: 255
    t.string "email", limit: 255
    t.string "invite_code", limit: 40
    t.datetime "invited_at", precision: nil
    t.datetime "redeemed_at", precision: nil
    t.boolean "glbrc_member"
    t.index ["id", "email"], name: "index_invites_on_id_and_email"
    t.index ["id", "invite_code"], name: "index_invites_on_id_and_invite_code"
  end

# Could not dump table "locations" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'


  create_table "public.measurement_scales", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "public.meeting_abstract_types", id: :serial, force: :cascade do |t|
    t.text "name"
    t.integer "order"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "public.meeting_abstracts", id: :serial, force: :cascade do |t|
    t.text "title"
    t.text "authors"
    t.text "abstract"
    t.integer "meeting_id"
    t.string "pdf_file_name", limit: 255
    t.string "pdf_content_type", limit: 255
    t.integer "pdf_file_size"
    t.datetime "pdf_updated_at", precision: nil
    t.text "author_affiliations"
    t.integer "meeting_abstract_type_id"
    t.datetime "updated_at", precision: nil
    t.text "abstract_backup"
    t.index ["meeting_id"], name: "index_meeting_abstracts_on_meeting_id"
  end

  create_table "public.meetings", id: :serial, force: :cascade do |t|
    t.date "date"
    t.string "title", limit: 255
    t.text "announcement"
    t.integer "venue_type_id"
    t.date "date_to"
    t.text "announcement_backup"
    t.index ["venue_type_id"], name: "index_meetings_on_venue_type_id"
  end

  create_table "public.memberships", id: :serial, force: :cascade do |t|
    t.integer "sponsor_id"
    t.integer "user_id"
    t.datetime "inserted_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }

    t.unique_constraint ["sponsor_id", "user_id"], nulls_not_distinct: true, name: "memberships_sponsor_id_user_id_key"
  end

  create_table "public.oban_jobs", comment: "12", force: :cascade do |t|
    t.enum "state", default: "available", null: false, enum_type: "public.oban_job_state"
    t.text "queue", default: "default", null: false
    t.text "worker", null: false
    t.jsonb "args", default: {}, null: false
    t.jsonb "errors", null: false, array: true
    t.integer "attempt", default: 0, null: false
    t.integer "max_attempts", default: 20, null: false
    t.datetime "inserted_at", precision: nil, default: -> { "timezone('UTC'::text, now())" }, null: false
    t.datetime "scheduled_at", precision: nil, default: -> { "timezone('UTC'::text, now())" }, null: false
    t.datetime "attempted_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.text "attempted_by", array: true
    t.datetime "discarded_at", precision: nil
    t.integer "priority", default: 0, null: false
    t.text "tags", array: true
    t.jsonb "meta", default: {}
    t.datetime "cancelled_at", precision: nil
    t.index ["args"], name: "oban_jobs_args_index", using: :gin
    t.index ["meta"], name: "oban_jobs_meta_index", using: :gin
    t.index ["state", "queue", "priority", "scheduled_at", "id"], name: "oban_jobs_state_queue_priority_scheduled_at_id_index"
    t.check_constraint "attempt >= 0 AND attempt <= max_attempts", name: "attempt_range"
    t.check_constraint "char_length(queue) > 0 AND char_length(queue) < 128", name: "queue_length"
    t.check_constraint "char_length(worker) > 0 AND char_length(worker) < 128", name: "worker_length"
    t.check_constraint "max_attempts > 0", name: "positive_max_attempts"
  end

  add_check_constraint "oban_jobs", "priority >= 0", name: "non_negative_priority", validate: false

  create_table "public.oban_peers", primary_key: "name", id: :text, force: :cascade do |t|
    t.text "node", null: false
    t.datetime "started_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil, null: false
  end

  create_table "public.ownerships", id: :serial, force: :cascade do |t|
    t.integer "datatable_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.index ["datatable_id"], name: "index_ownerships_on_datatable_id"
    t.index ["user_id"], name: "index_ownerships_on_user_id"
  end

  create_table "public.page_images", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.string "attribution", limit: 255
    t.integer "page_id"
    t.string "image_file_name", limit: 255
    t.string "image_content_type", limit: 255
    t.integer "image_file_size"
    t.datetime "image_updated_at", precision: nil
    t.index ["page_id"], name: "index_page_images_on_page_id"
  end

  create_table "public.pages", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.text "body"
    t.string "url", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "body_backup"
    t.boolean "body_markdown", default: false
  end

  create_table "public.people", id: :serial, force: :cascade do |t|
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
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.string "orcid_id"
    t.integer "graduation_year"
    t.integer "thesis_id"
    t.text "lter_awards"
    t.boolean "lter_thesis", default: false
    t.text "thesis_url"
    t.string "thesis_type", limit: 3
    t.string "lno_contact_id", limit: 255
    t.text "lno_name"

    t.unique_constraint ["email"], name: "people_email_key"
    t.unique_constraint ["lno_contact_id"], name: "people_lno_contact_id_key"
    t.unique_constraint ["sur_name", "given_name", "middle_name", "friendly_name"], name: "people_sur_name_given_name_middle_name_friendly_name_key"
  end

  create_table "public.permission_requests", id: :serial, force: :cascade do |t|
    t.integer "datatable_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["datatable_id"], name: "index_permission_requests_on_datatable_id"
    t.index ["user_id"], name: "index_permission_requests_on_user_id"
  end

  create_table "public.permissions", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "datatable_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "owner_id"
    t.string "decision", limit: 255
    t.date "expires_on"
    t.datetime "expiry_reminder_sent_at"
    t.text "intended_use"
    t.string "site"
    t.index ["datatable_id"], name: "index_permissions_on_datatable_id"
    t.index ["owner_id"], name: "index_permissions_on_owner_id"
    t.index ["user_id", "datatable_id"], name: "index_permissions_on_user_id_and_datatable_id", unique: true
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "public.permissions_legacy", id: false, force: :cascade do |t|
    t.integer "id"
    t.integer "user_id"
    t.integer "datatable_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "owner_id"
    t.string "decision", limit: 255
  end

  create_table "public.person_projects", force: :cascade do |t|
    t.integer "person_id"
    t.integer "project_id"
    t.integer "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "public.projects", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.text "abstract"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "funder_name"
    t.string "funder_identifier"
    t.string "award_number"
    t.string "award_url"
    t.text "organizationName"
    t.text "role"
  end

  create_table "public.protocols", id: :integer, default: -> { "nextval('methocols_id_seq'::regclass)" }, force: :cascade do |t|
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
    t.datetime "pdf_updated_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "created_at", precision: nil
    t.text "body_backup"
    t.text "description_backup"
    t.text "abstract_backup"
    t.text "change_summary_backup"
    t.index ["dataset_id"], name: "index_protocols_on_dataset_id"
    t.index ["person_id"], name: "index_protocols_on_person_id"
  end

  create_table "public.protocols_sponsors", id: false, force: :cascade do |t|
    t.integer "protocol_id"
    t.integer "sponsor_id"
    t.index ["protocol_id"], name: "index_protocols_sponsors_on_protocol_id"
    t.index ["sponsor_id"], name: "index_protocols_sponsors_on_sponsor_id"
  end

  create_table "public.protocols_websites", id: false, force: :cascade do |t|
    t.integer "protocol_id"
    t.integer "website_id"
    t.index ["protocol_id"], name: "index_protocols_websites_on_protocol_id"
    t.index ["website_id"], name: "index_protocols_websites_on_website_id"
  end

  create_table "public.publication_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "public.publications", id: :serial, force: :cascade do |t|
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

  create_table "public.publications_treatments", id: false, force: :cascade do |t|
    t.integer "treatment_id"
    t.integer "publication_id"
    t.index ["publication_id"], name: "index_publications_treatments_on_publication_id"
    t.index ["treatment_id"], name: "index_publications_treatments_on_treatment_id"
  end

  create_table "public.replicates", id: false, force: :cascade do |t|
    t.string "replicate", limit: 50, null: false
    t.string "description", limit: 255
  end

  create_table "public.replication_check", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.timestamptz "value"
  end

  create_table "public.role_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "public.roles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "role_type_id"
    t.integer "seniority"
    t.boolean "show_in_overview", default: true
    t.boolean "show_in_detailview", default: true
    t.index ["role_type_id"], name: "index_roles_on_role_type_id"
  end

  create_table "public.scribbles", id: :serial, force: :cascade do |t|
    t.integer "person_id"
    t.integer "protocol_id"
    t.integer "weight"
    t.index ["person_id"], name: "index_scribbles_on_person_id"
    t.index ["protocol_id"], name: "index_scribbles_on_protocol_id"
  end

  create_table "public.sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", limit: 255
    t.text "data"
    t.datetime "updated_at", precision: nil
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "public.site", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "geometry"
  end

  create_table "public.sites", id: :serial, force: :cascade do |t|
    t.string "sitename", limit: 255, null: false
    t.text "description"
    t.date "start_date"
    t.date "end_date"
    t.string "sitecode", limit: 255
    t.datetime "updated_at", precision: nil
    t.datetime "created_at", precision: nil
  end

  create_table "public.slugs", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "sluggable_id"
    t.integer "sequence", default: 1, null: false
    t.string "sluggable_type", limit: 40
    t.string "scope", limit: 255
    t.datetime "created_at", precision: nil
    t.index ["name", "sluggable_type", "sequence", "scope"], name: "index_slugs_on_n_s_s_and_s", unique: true
    t.index ["sluggable_id"], name: "index_slugs_on_sluggable_id"
  end

  create_table "public.solid_queue_batch_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "batch_id", null: false
    t.datetime "created_at", null: false
    t.index ["batch_id"], name: "index_solid_queue_batch_executions_on_batch_id"
    t.index ["job_id"], name: "index_solid_queue_batch_executions_on_job_id", unique: true
  end

  create_table "public.solid_queue_batches", force: :cascade do |t|
    t.string "active_job_batch_id"
    t.string "description"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_failure"
    t.text "metadata"
    t.integer "total_jobs", default: 0, null: false
    t.integer "completed_jobs", default: 0, null: false
    t.integer "failed_jobs", default: 0, null: false
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.datetime "failed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_batch_id"], name: "index_solid_queue_batches_on_active_job_batch_id", unique: true
    t.index ["finished_at"], name: "index_solid_queue_batches_on_finished_at"
  end

  create_table "public.solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "public.solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "public.solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "public.solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "batch_id"
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["batch_id"], name: "index_solid_queue_jobs_on_batch_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "public.solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "public.solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "public.solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "public.solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "public.solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "public.solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "public.solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "public.sources", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
  end

  create_table "public.spatial_ref_sys", primary_key: "srid", id: :integer, default: nil, force: :cascade do |t|
    t.string "auth_name", limit: 256
    t.integer "auth_srid"
    t.string "srtext", limit: 2048
    t.string "proj4text", limit: 2048
    t.check_constraint "srid > 0 AND srid <= 998999", name: "spatial_ref_sys_srid_check"
  end

  create_table "public.species_transect_schema_migrations", primary_key: "version", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime "inserted_at", precision: 0
  end

  create_table "public.sponsors", id: :serial, comment: "Control the accessibility of data", force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "data_restricted", default: false
    t.text "data_use_statement"
    t.string "terms_of_use_url"
    t.text "data_use_statement_backup"
  end

  create_table "public.studies", id: :serial, force: :cascade do |t|
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
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.string "short_name", limit: 255
    t.index ["code"], name: "studies_code_uindex", unique: true
    t.index ["name"], name: "studies_index_4", unique: true
    t.index ["parent_id"], name: "index_studies_on_parent_id"
  end

  create_table "public.study_urls", id: :serial, force: :cascade do |t|
    t.integer "website_id"
    t.integer "study_id"
    t.string "url", limit: 255
  end

  create_table "public.taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.integer "tagger_id"
    t.string "tagger_type", limit: 255
    t.string "taggable_type", limit: 255
    t.string "context", limit: 255
    t.datetime "created_at", precision: nil
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "public.tags", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "public.templates", id: :serial, force: :cascade do |t|
    t.integer "website_id"
    t.string "controller", limit: 255
    t.string "action", limit: 255
    t.text "layout"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["website_id"], name: "index_templates_on_website_id"
  end

  create_table "public.themes", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "weight"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.datetime "updated_at", precision: nil
    t.datetime "created_at", precision: nil
    t.index ["name", "parent_id"], name: "themes_name_parent_id_uindex", unique: true
    t.index ["parent_id"], name: "index_themes_on_parent_id"
  end

  create_table "public.treatments", id: :serial, force: :cascade do |t|
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
    t.bigint "project_id"
    t.integer "parent_id"
    t.integer "rgt", null: false
    t.integer "lft", null: false
    t.index ["lft", "rgt"], name: "treatments_lft_rgt_idx"
    t.index ["project_id"], name: "index_treatments_on_project_id"
    t.index ["study_id"], name: "index_treatments_on_study_id"
  end

  create_table "public.units", id: :serial, force: :cascade do |t|
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
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.datetime "inserted_at", precision: nil

    t.unique_constraint ["name"], name: "unit_names_key"
  end

  create_table "public.users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255
    t.string "encrypted_password", limit: 128
    t.string "salt", limit: 128
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128
    t.boolean "email_confirmed", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "identity_url", limit: 255
    t.string "role", limit: 255
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "provider"
    t.string "uid"
    t.datetime "inserted_at", precision: nil
    t.datetime "confirmed_at", precision: nil
    t.string "hashed_password", limit: 256
    t.text "last_glbrc_groups", default: [], null: false, array: true
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "first_name"
    t.string "last_name"
    t.string "institution"
    t.index ["email"], name: "index_users_on_email"
    t.index ["id", "confirmation_token"], name: "index_users_on_id_and_confirmation_token"
    t.index ["identity_url"], name: "index_users_on_identity_url", unique: true
    t.index ["remember_token"], name: "index_users_on_remember_token"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.unique_constraint ["email"], name: "users_email_key"
  end

  create_table "public.users_tokens", id: :serial, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.binary "token", null: false
    t.string "context", limit: 255, null: false
    t.string "sent_to", limit: 255
    t.datetime "inserted_at", precision: 0, null: false
    t.index ["context", "token"], name: "users_tokens_context_token_index", unique: true
    t.index ["user_id"], name: "users_tokens_user_id_index"
  end

  create_table "public.variates", id: :serial, force: :cascade do |t|
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
    t.datetime "inserted_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.index ["datatable_id"], name: "index_variates_on_datatable_id"
    t.index ["unit_id"], name: "index_variates_on_unit_id"
    t.index ["variate_theme_id"], name: "index_variates_on_variate_theme_id"
  end

  create_table "public.venue_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
  end

  create_table "public.versions", id: :serial, force: :cascade do |t|
    t.integer "versioned_id"
    t.string "versioned_type", limit: 255
    t.integer "user_id"
    t.string "user_type", limit: 255
    t.string "user_name", limit: 255
    t.text "modifications"
    t.integer "number"
    t.integer "reverted_from"
    t.string "tag", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["created_at"], name: "index_versions_on_created_at"
    t.index ["number"], name: "index_versions_on_number"
    t.index ["tag"], name: "index_versions_on_tag"
    t.index ["user_id", "user_type"], name: "index_versions_on_user_id_and_user_type"
    t.index ["user_name"], name: "index_versions_on_user_name"
    t.index ["versioned_id", "versioned_type"], name: "index_versions_on_versioned_id_and_versioned_type"
  end

  create_table "public.visualizations", id: :serial, force: :cascade do |t|
    t.integer "datatable_id"
    t.string "title", limit: 255
    t.text "body"
    t.text "query"
    t.string "graph_type", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "x_axis_label", limit: 255
    t.string "y_axis_label", limit: 255
    t.integer "weight"
  end

  create_table "public.websites", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "data_catalog_intro"
    t.text "url"
  end

  add_foreign_key "public.active_storage_attachments", "public.active_storage_blobs", column: "blob_id"
  add_foreign_key "public.active_storage_variant_records", "public.active_storage_blobs", column: "blob_id"
  add_foreign_key "public.affiliations", "public.people", name: "affiliations_person_id_fkey"
  add_foreign_key "public.affiliations", "public.roles", name: "affiliations_role_id_fkey1"
  add_foreign_key "public.authors", "public.citations", name: "authors_citation_id_fk"
  add_foreign_key "public.authors", "public.citations", name: "authors_citation_id_fkey"
  add_foreign_key "public.citations_treatments", "public.citations", name: "citations_treatments_citation_id_fkey", validate: false
  add_foreign_key "public.citations_treatments", "public.treatments", name: "citations_treatments_treatment_id_fkey", validate: false
  add_foreign_key "public.data_contributions", "public.datatables", name: "data_contributions_datatable_id_fkey", validate: false
  add_foreign_key "public.data_contributions", "public.people", name: "data_contributions_person_id_fkey", validate: false
  add_foreign_key "public.data_contributions", "public.roles", name: "data_contributions_role_id_fkey", validate: false
  add_foreign_key "public.dataset_dois", "public.datasets", name: "dataset_dois_datasets_id_fk"
  add_foreign_key "public.datasets", "public.projects", name: "datasets_projects_id_fk"
  add_foreign_key "public.datasets", "public.sponsors", name: "sponsorsdatasets___fk"
  add_foreign_key "public.datasets", "public.websites", name: "datasets_website_id_fkey", validate: false
  add_foreign_key "public.datatables", "public.datasets", name: "datatables_dataset_id_fkey", on_update: :restrict, on_delete: :restrict
  add_foreign_key "public.datatables", "public.studies", name: "datatables_study_id_fkey", validate: false
  add_foreign_key "public.datatables", "public.themes", name: "datatables_theme_id_fkey", validate: false
  add_foreign_key "public.datatables_dois", "public.datatables", name: "datatables_dois_datatable_id_fkey", validate: false
  add_foreign_key "public.editors", "public.citations", name: "editors_citation_id_fk"
  add_foreign_key "public.editors", "public.citations", name: "editors_citation_id_fkey"
  add_foreign_key "public.memberships", "public.sponsors", name: "memberships_sponsor_id_fkey", validate: false
  add_foreign_key "public.memberships", "public.users", name: "memberships_user_id_fkey", on_delete: :cascade, validate: false
  add_foreign_key "public.ownerships", "public.datatables", name: "ownerships_datatable_id_fkey", validate: false
  add_foreign_key "public.ownerships", "public.users", name: "ownerships_user_id_fkey", validate: false
  add_foreign_key "public.permission_requests", "public.datatables", on_delete: :cascade
  add_foreign_key "public.permission_requests", "public.users", on_delete: :cascade
  add_foreign_key "public.permissions", "public.datatables", on_delete: :cascade
  add_foreign_key "public.permissions", "public.users", column: "owner_id", on_delete: :nullify
  add_foreign_key "public.permissions", "public.users", on_delete: :cascade
  add_foreign_key "public.roles", "public.role_types", name: "roles_role_type_id_fkey", validate: false
  add_foreign_key "public.solid_queue_batch_executions", "public.solid_queue_batches", column: "batch_id", on_delete: :cascade
  add_foreign_key "public.solid_queue_batch_executions", "public.solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "public.solid_queue_blocked_executions", "public.solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "public.solid_queue_claimed_executions", "public.solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "public.solid_queue_failed_executions", "public.solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "public.solid_queue_ready_executions", "public.solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "public.solid_queue_recurring_executions", "public.solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "public.solid_queue_scheduled_executions", "public.solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "public.studies", "public.studies", column: "parent_id", name: "studies_parent_id_fkey", validate: false
  add_foreign_key "public.themes", "public.themes", column: "parent_id", name: "themes_parent_id_fkey", validate: false
  add_foreign_key "public.treatments", "public.projects"
  add_foreign_key "public.users_tokens", "public.users", name: "users_tokens_user_id_fkey", on_delete: :cascade
  add_foreign_key "public.variates", "public.datatables", name: "variates_datatable_id_fkey"
  add_foreign_key "public.variates", "public.units", name: "variates_unit_id_fkey"

  create_table "topology.layer", primary_key: ["topology_id", "layer_id"], force: :cascade do |t|
    t.integer "topology_id", null: false
    t.integer "layer_id", null: false
    t.string "schema_name", null: false
    t.string "table_name", null: false
    t.string "feature_column", null: false
    t.integer "feature_type", null: false
    t.integer "level", default: 0, null: false
    t.integer "child_id"

    t.unique_constraint ["schema_name", "table_name", "feature_column"], name: "layer_schema_name_table_name_feature_column_key"
  end

  create_table "topology.topology", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "srid", null: false
    t.float "precision", null: false
    t.boolean "hasz", default: false, null: false
    t.boolean "useslargeids", default: false, null: false

    t.unique_constraint ["name"], name: "topology_name_key"
  end

  add_foreign_key "topology.layer", "topology.topology", name: "layer_topology_id_fkey"
end
