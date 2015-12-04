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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151204212403) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "fuzzystrmatch"

  create_table "affiliations", force: :cascade do |t|
    t.integer "person_id"
    t.integer "role_id"
    t.integer "dataset_id"
    t.integer "seniority"
    t.string  "title",             limit: 255
    t.string  "supervisor",        limit: 255
    t.date    "started_on"
    t.date    "left_on"
    t.string  "research_interest", limit: 255
  end

  add_index "affiliations", ["dataset_id"], name: "index_affiliations_on_dataset_id", using: :btree
  add_index "affiliations", ["person_id"], name: "index_affiliations_on_person_id", using: :btree
  add_index "affiliations", ["role_id"], name: "index_affiliations_on_role_id", using: :btree

  create_table "authors", force: :cascade do |t|
    t.string   "sur_name",    limit: 255
    t.string   "given_name",  limit: 255
    t.string   "middle_name", limit: 255
    t.integer  "seniority"
    t.integer  "person_id"
    t.integer  "citation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "suffix",      limit: 255
  end

  add_index "authors", ["citation_id"], name: "index_authors_on_citation_id", using: :btree
  add_index "authors", ["person_id"], name: "index_authors_on_person_id", using: :btree

  create_table "citation_types", force: :cascade do |t|
    t.string   "abbreviation", limit: 255
    t.string   "name",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "citations", force: :cascade do |t|
    t.text     "title"
    t.text     "abstract"
    t.date     "pub_date"
    t.integer  "pub_year"
    t.integer  "citation_type_id"
    t.text     "address"
    t.text     "notes"
    t.string   "publication",              limit: 255
    t.string   "start_page_number",        limit: 255
    t.string   "ending_page_number",       limit: 255
    t.text     "periodical_full_name"
    t.string   "periodical_abbreviation",  limit: 255
    t.string   "volume",                   limit: 255
    t.string   "issue",                    limit: 255
    t.string   "city",                     limit: 255
    t.string   "publisher",                limit: 255
    t.string   "secondary_title",          limit: 255
    t.string   "series_title",             limit: 255
    t.string   "isbn",                     limit: 255
    t.string   "doi",                      limit: 255
    t.text     "full_text"
    t.string   "publisher_url",            limit: 255
    t.integer  "website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pdf_file_name",            limit: 255
    t.string   "pdf_content_type",         limit: 255
    t.integer  "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.string   "state",                    limit: 255
    t.boolean  "open_access",                          default: false
    t.string   "type",                     limit: 255
    t.boolean  "has_lter_acknowledgement"
    t.string   "annotation",               limit: 255
    t.string   "data_url"
  end

  add_index "citations", ["citation_type_id"], name: "index_citations_on_citation_type_id", using: :btree
  add_index "citations", ["website_id"], name: "index_citations_on_website_id", using: :btree

  create_table "citations_datatables", id: false, force: :cascade do |t|
    t.integer "citation_id"
    t.integer "datatable_id"
  end

  create_table "citations_treatments", id: false, force: :cascade do |t|
    t.integer "citation_id"
    t.integer "treatment_id"
  end

  create_table "collections", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "datatable_id"
  end

  add_index "collections", ["datatable_id"], name: "index_collections_on_datatable_id", using: :btree

  create_table "columns", force: :cascade do |t|
    t.integer "datatable_id"
    t.integer "variate_id"
    t.integer "position"
    t.string  "name",         limit: 255
  end

  add_index "columns", ["datatable_id"], name: "index_columns_on_datatable_id", using: :btree
  add_index "columns", ["variate_id"], name: "index_columns_on_variate_id", using: :btree

  create_table "core_areas", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "core_areas_datatables", force: :cascade do |t|
    t.integer "core_area_id"
    t.integer "datatable_id"
  end

  create_table "data_contributions", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "datatable_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seniority"
  end

  add_index "data_contributions", ["datatable_id", "person_id", "role_id"], name: "data_contributions_uniq_idx", unique: true, using: :btree

  create_table "datafiles", force: :cascade do |t|
    t.text     "title"
    t.text     "description"
    t.string   "original_data_file_name",    limit: 255
    t.string   "original_data_content_type", limit: 255
    t.integer  "original_data_file_size"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "datafiles", ["person_id"], name: "index_datafiles_on_person_id", using: :btree

  create_table "dataset_files", force: :cascade do |t|
    t.text     "name"
    t.integer  "dataset_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "data_file_name",    limit: 255
    t.string   "data_content_type", limit: 255
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
  end

  create_table "datasets", force: :cascade do |t|
    t.string   "dataset",       limit: 255
    t.string   "title",         limit: 255
    t.text     "abstract"
    t.string   "old_keywords",  limit: 255
    t.string   "status",        limit: 255
    t.date     "initiated"
    t.date     "completed"
    t.date     "released"
    t.boolean  "on_web",                    default: true
    t.integer  "version",                   default: 1
    t.boolean  "core_dataset",              default: false
    t.integer  "project_id"
    t.integer  "metacat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sponsor_id"
    t.integer  "website_id"
    t.boolean  "pasta_ready",               default: false
    t.date     "data_end_date"
  end

  add_index "datasets", ["dataset"], name: "datasets_dataset_key", unique: true, using: :btree
  add_index "datasets", ["metacat_id"], name: "index_datasets_on_metacat_id", using: :btree
  add_index "datasets", ["project_id"], name: "index_datasets_on_project_id", using: :btree
  add_index "datasets", ["sponsor_id"], name: "index_datasets_on_sponsor_id", using: :btree
  add_index "datasets", ["website_id"], name: "index_datasets_on_website_id", using: :btree

  create_table "datasets_studies", id: false, force: :cascade do |t|
    t.integer "dataset_id"
    t.integer "study_id"
  end

  add_index "datasets_studies", ["dataset_id"], name: "index_datasets_studies_on_dataset_id", using: :btree
  add_index "datasets_studies", ["study_id"], name: "index_datasets_studies_on_study_id", using: :btree

  create_table "datasets_themes", id: false, force: :cascade do |t|
    t.integer "theme_id"
    t.integer "dataset_id"
  end

  add_index "datasets_themes", ["dataset_id"], name: "index_datasets_themes_on_dataset_id", using: :btree
  add_index "datasets_themes", ["theme_id"], name: "index_datasets_themes_on_theme_id", using: :btree

  create_table "datatables", force: :cascade do |t|
    t.string   "name",                       limit: 255
    t.string   "title",                      limit: 255
    t.text     "comments"
    t.integer  "dataset_id"
    t.string   "data_url",                   limit: 255
    t.string   "connection_url",             limit: 255
    t.string   "driver",                     limit: 255
    t.boolean  "is_restricted"
    t.text     "description"
    t.text     "object"
    t.string   "metadata_url",               limit: 255
    t.boolean  "is_sql"
    t.integer  "update_frequency_days"
    t.date     "last_updated_on"
    t.text     "access_statement"
    t.integer  "excerpt_limit"
    t.date     "begin_date"
    t.date     "end_date"
    t.boolean  "on_web",                                 default: true
    t.integer  "theme_id"
    t.integer  "core_area_id"
    t.integer  "weight",                                 default: 100
    t.integer  "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_secondary",                           default: false
    t.boolean  "is_utf_8",                               default: false
    t.boolean  "metadata_only",                          default: false
    t.text     "summary_graph"
    t.integer  "deprecated_in_fovor_of"
    t.text     "deprecation_notice"
    t.integer  "number_of_released_records"
    t.text     "scores"
    t.date     "completed_on"
    t.text     "workflow_state"
    t.string   "csv_cache_file_name",        limit: 255
    t.string   "csv_cache_content_type",     limit: 255
    t.integer  "csv_cache_file_size"
    t.datetime "csv_cache_updated_at"
    t.integer  "update_cache_days"
  end

  add_index "datatables", ["core_area_id"], name: "index_datatables_on_core_area_id", using: :btree
  add_index "datatables", ["dataset_id"], name: "index_datatables_on_dataset_id", using: :btree
  add_index "datatables", ["name"], name: "datatables_name_key", unique: true, using: :btree
  add_index "datatables", ["study_id"], name: "index_datatables_on_study_id", using: :btree
  add_index "datatables", ["theme_id"], name: "index_datatables_on_theme_id", using: :btree

  create_table "datatables_protocols", id: false, force: :cascade do |t|
    t.integer "datatable_id", null: false
    t.integer "protocol_id",  null: false
  end

  add_index "datatables_protocols", ["datatable_id"], name: "index_datatables_protocols_on_datatable_id", using: :btree
  add_index "datatables_protocols", ["protocol_id"], name: "index_datatables_protocols_on_protocol_id", using: :btree

  create_table "datatables_variates", force: :cascade do |t|
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0
    t.integer  "attempts",               default: 0
    t.text     "handler"
    t.string   "last_error", limit: 255
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "editors", force: :cascade do |t|
    t.string   "sur_name",    limit: 255
    t.string   "given_name",  limit: 255
    t.string   "middle_name", limit: 255
    t.integer  "seniority"
    t.integer  "person_id"
    t.integer  "citation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "suffix",      limit: 255
  end

  create_table "eml_docs", force: :cascade do |t|
  end

  create_table "invites", force: :cascade do |t|
    t.string   "firstname",    limit: 255
    t.string   "lastname",     limit: 255
    t.string   "email",        limit: 255
    t.string   "invite_code",  limit: 40
    t.datetime "invited_at"
    t.datetime "redeemed_at"
    t.boolean  "glbrc_member"
  end

  add_index "invites", ["id", "email"], name: "index_invites_on_id_and_email", using: :btree
  add_index "invites", ["id", "invite_code"], name: "index_invites_on_id_and_invite_code", using: :btree

  create_table "measurement_scales", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "meeting_abstract_types", force: :cascade do |t|
    t.text     "name"
    t.integer  "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meeting_abstracts", force: :cascade do |t|
    t.text     "title"
    t.text     "authors"
    t.text     "abstract"
    t.integer  "meeting_id"
    t.string   "pdf_file_name",            limit: 255
    t.string   "pdf_content_type",         limit: 255
    t.integer  "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.text     "author_affiliations"
    t.integer  "meeting_abstract_type_id"
  end

  add_index "meeting_abstracts", ["meeting_id"], name: "index_meeting_abstracts_on_meeting_id", using: :btree

  create_table "meetings", force: :cascade do |t|
    t.date    "date"
    t.string  "title",         limit: 255
    t.text    "announcement"
    t.integer "venue_type_id"
    t.date    "date_to"
  end

  add_index "meetings", ["venue_type_id"], name: "index_meetings_on_venue_type_id", using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer "sponsor_id"
    t.integer "user_id"
  end

  create_table "open_id_associations", force: :cascade do |t|
    t.binary  "server_url"
    t.string  "handle",     limit: 255
    t.binary  "secret"
    t.integer "issued"
    t.integer "lifetime"
    t.string  "assoc_type", limit: 255
  end

  create_table "open_id_authentication_associations", force: :cascade do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle",     limit: 255
    t.string  "assoc_type", limit: 255
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", force: :cascade do |t|
    t.integer "timestamp",              null: false
    t.string  "server_url", limit: 255
    t.string  "salt",       limit: 255, null: false
  end

  create_table "open_id_nonces", force: :cascade do |t|
    t.string  "nonce",   limit: 255
    t.integer "created"
  end

  create_table "open_id_settings", force: :cascade do |t|
    t.string "setting", limit: 255
    t.binary "value"
  end

  create_table "ownerships", force: :cascade do |t|
    t.integer  "datatable_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ownerships", ["datatable_id"], name: "index_ownerships_on_datatable_id", using: :btree
  add_index "ownerships", ["user_id"], name: "index_ownerships_on_user_id", using: :btree

  create_table "page_images", force: :cascade do |t|
    t.string   "title",              limit: 255
    t.string   "attribution",        limit: 255
    t.integer  "page_id"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "page_images", ["page_id"], name: "index_page_images_on_page_id", using: :btree

  create_table "pages", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "body"
    t.string   "url",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", force: :cascade do |t|
    t.string   "person",           limit: 255
    t.string   "sur_name",         limit: 255
    t.string   "given_name",       limit: 255
    t.string   "middle_name",      limit: 255
    t.string   "friendly_name",    limit: 255
    t.string   "title",            limit: 255
    t.string   "sub_organization", limit: 255
    t.string   "organization",     limit: 255
    t.string   "street_address",   limit: 255
    t.string   "city",             limit: 255
    t.string   "locale",           limit: 255
    t.string   "country",          limit: 255
    t.string   "postal_code",      limit: 255
    t.string   "phone",            limit: 255
    t.string   "fax",              limit: 255
    t.string   "email",            limit: 255
    t.string   "url",              limit: 255
    t.boolean  "deceased"
    t.string   "open_id",          limit: 255
    t.boolean  "is_postdoc"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.string   "orcid"
  end

  add_index "people", ["sur_name", "given_name", "middle_name", "friendly_name"], name: "people_sur_name_given_name_middle_name_friendly_name_key", unique: true, using: :btree

  create_table "permission_requests", force: :cascade do |t|
    t.integer  "datatable_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permission_requests", ["datatable_id"], name: "index_permission_requests_on_datatable_id", using: :btree
  add_index "permission_requests", ["user_id"], name: "index_permission_requests_on_user_id", using: :btree

  create_table "permissions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "datatable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "decision",     limit: 255
  end

  add_index "permissions", ["datatable_id"], name: "index_permissions_on_datatable_id", using: :btree
  add_index "permissions", ["owner_id"], name: "index_permissions_on_owner_id", using: :btree
  add_index "permissions", ["user_id"], name: "index_permissions_on_user_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "abstract"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "protocols", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "title",            limit: 255
    t.integer  "version_tag",                  default: 1
    t.date     "in_use_from"
    t.date     "in_use_to"
    t.text     "description"
    t.text     "abstract"
    t.text     "body"
    t.integer  "person_id"
    t.date     "created_on"
    t.date     "updated_on"
    t.text     "change_summary"
    t.integer  "dataset_id"
    t.boolean  "active",                       default: true
    t.integer  "deprecates"
    t.string   "pdf_file_name",    limit: 255
    t.string   "pdf_content_type", limit: 255
    t.integer  "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "protocols", ["dataset_id"], name: "index_protocols_on_dataset_id", using: :btree
  add_index "protocols", ["person_id"], name: "index_protocols_on_person_id", using: :btree

  create_table "protocols_sponsors", id: false, force: :cascade do |t|
    t.integer "protocol_id"
    t.integer "sponsor_id"
  end

  add_index "protocols_sponsors", ["protocol_id"], name: "index_protocols_sponsors_on_protocol_id", using: :btree
  add_index "protocols_sponsors", ["sponsor_id"], name: "index_protocols_sponsors_on_sponsor_id", using: :btree

  create_table "protocols_websites", id: false, force: :cascade do |t|
    t.integer "protocol_id"
    t.integer "website_id"
  end

  add_index "protocols_websites", ["protocol_id"], name: "index_protocols_websites_on_protocol_id", using: :btree
  add_index "protocols_websites", ["website_id"], name: "index_protocols_websites_on_website_id", using: :btree

  create_table "publication_types", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "publications", force: :cascade do |t|
    t.integer "publication_type_id"
    t.text    "citation"
    t.text    "abstract"
    t.integer "year"
    t.string  "file_url",            limit: 255
    t.text    "title"
    t.text    "authors"
    t.integer "source_id"
    t.integer "parent_id"
    t.string  "content_type",        limit: 255
    t.string  "filename",            limit: 255
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.boolean "deprecated"
  end

  add_index "publications", ["parent_id"], name: "index_publications_on_parent_id", using: :btree
  add_index "publications", ["publication_type_id"], name: "index_publications_on_publication_type_id", using: :btree
  add_index "publications", ["source_id"], name: "index_publications_on_source_id", using: :btree

  create_table "publications_treatments", id: false, force: :cascade do |t|
    t.integer "treatment_id"
    t.integer "publication_id"
  end

  add_index "publications_treatments", ["publication_id"], name: "index_publications_treatments_on_publication_id", using: :btree
  add_index "publications_treatments", ["treatment_id"], name: "index_publications_treatments_on_treatment_id", using: :btree

  create_table "replicates", id: false, force: :cascade do |t|
    t.string "replicate",   limit: 50,  null: false
    t.string "description", limit: 255
  end

  create_table "replication_check", id: false, force: :cascade do |t|
    t.integer  "id",    default: "nextval('replication_check_id_seq'::regclass)", null: false
    t.datetime "value"
  end

  create_table "role_types", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "roles", force: :cascade do |t|
    t.string  "name",               limit: 255
    t.integer "role_type_id"
    t.integer "seniority"
    t.boolean "show_in_overview",               default: true
    t.boolean "show_in_detailview",             default: true
    t.date    "arrived_on"
    t.date    "departed_on"
  end

  add_index "roles", ["role_type_id"], name: "index_roles_on_role_type_id", using: :btree

  create_table "scribbles", force: :cascade do |t|
    t.integer "person_id"
    t.integer "protocol_id"
    t.integer "weight"
  end

  add_index "scribbles", ["person_id"], name: "index_scribbles_on_person_id", using: :btree
  add_index "scribbles", ["protocol_id"], name: "index_scribbles_on_protocol_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "slugs", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "sluggable_id"
    t.integer  "sequence",                   default: 1, null: false
    t.string   "sluggable_type", limit: 40
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], name: "index_slugs_on_n_s_s_and_s", unique: true, using: :btree
  add_index "slugs", ["sluggable_id"], name: "index_slugs_on_sluggable_id", using: :btree

  create_table "sources", force: :cascade do |t|
    t.string "title", limit: 255
  end

  create_table "sponsors", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "data_restricted",                default: false
    t.text     "data_use_statement"
    t.string   "terms_of_use_url"
  end

  create_table "studies", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description"
    t.integer  "weight"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.text     "synopsis"
    t.string   "url",         limit: 255
    t.string   "code",        limit: 255
    t.text     "warning"
    t.text     "source"
    t.text     "old_names"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "studies", ["parent_id"], name: "index_studies_on_parent_id", using: :btree

  create_table "study_urls", force: :cascade do |t|
    t.integer "website_id"
    t.integer "study_id"
    t.string  "url",        limit: 255
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type",   limit: 255
    t.string   "taggable_type", limit: 255
    t.string   "context",       limit: 255
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  add_index "taggings", ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count",             default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "templates", force: :cascade do |t|
    t.integer  "website_id"
    t.string   "controller", limit: 255
    t.string   "action",     limit: 255
    t.text     "layout"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "templates", ["website_id"], name: "index_templates_on_website_id", using: :btree

  create_table "themes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "weight"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "themes", ["parent_id"], name: "index_themes_on_parent_id", using: :btree

  create_table "treatments", force: :cascade do |t|
    t.string  "name",             limit: 255
    t.text    "description"
    t.integer "study_id"
    t.integer "weight"
    t.text    "deprecated_names"
    t.text    "management"
    t.text    "dominant_plants"
    t.date    "start_date"
    t.date    "end_date"
    t.boolean "use_in_citations",             default: true
  end

  add_index "treatments", ["study_id"], name: "index_treatments_on_study_id", using: :btree

  create_table "units", force: :cascade do |t|
    t.string  "name",                   limit: 255
    t.text    "description"
    t.boolean "in_eml",                             default: false
    t.text    "definition"
    t.integer "deprecated_in_favor_of"
    t.string  "unit_type",              limit: 255
    t.string  "parent_si",              limit: 255
    t.float   "multiplier_to_si"
    t.string  "abbreviation"
    t.string  "label",                  limit: 255
    t.float   "offset_to_si"
  end

  add_index "units", ["name"], name: "unit_names_key", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",              limit: 255
    t.string   "encrypted_password", limit: 128
    t.string   "salt",               limit: 128
    t.string   "confirmation_token", limit: 128
    t.string   "remember_token",     limit: 128
    t.boolean  "email_confirmed",                default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identity_url",       limit: 255
    t.string   "role",               limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["email"], name: "users_email_key", unique: true, using: :btree
  add_index "users", ["id", "confirmation_token"], name: "index_users_on_id_and_confirmation_token", using: :btree
  add_index "users", ["identity_url"], name: "index_users_on_identity_url", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  create_table "variates", force: :cascade do |t|
    t.string  "name",                    limit: 255
    t.integer "datatable_id"
    t.integer "weight"
    t.text    "description"
    t.string  "missing_value_indicator", limit: 255
    t.integer "unit_id"
    t.string  "measurement_scale",       limit: 255
    t.string  "data_type",               limit: 255
    t.float   "min_valid"
    t.float   "max_valid"
    t.string  "date_format",             limit: 255
    t.float   "precision"
    t.text    "query"
    t.integer "variate_theme_id"
  end

  add_index "variates", ["datatable_id"], name: "index_variates_on_datatable_id", using: :btree
  add_index "variates", ["unit_id"], name: "index_variates_on_unit_id", using: :btree
  add_index "variates", ["variate_theme_id"], name: "index_variates_on_variate_theme_id", using: :btree

  create_table "venue_types", force: :cascade do |t|
    t.string "name",        limit: 255
    t.text   "description"
  end

  create_table "versions", force: :cascade do |t|
    t.integer  "versioned_id"
    t.string   "versioned_type", limit: 255
    t.integer  "user_id"
    t.string   "user_type",      limit: 255
    t.string   "user_name",      limit: 255
    t.text     "modifications"
    t.integer  "number"
    t.integer  "reverted_from"
    t.string   "tag",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["created_at"], name: "index_versions_on_created_at", using: :btree
  add_index "versions", ["number"], name: "index_versions_on_number", using: :btree
  add_index "versions", ["tag"], name: "index_versions_on_tag", using: :btree
  add_index "versions", ["user_id", "user_type"], name: "index_versions_on_user_id_and_user_type", using: :btree
  add_index "versions", ["user_name"], name: "index_versions_on_user_name", using: :btree
  add_index "versions", ["versioned_id", "versioned_type"], name: "index_versions_on_versioned_id_and_versioned_type", using: :btree

  create_table "visualizations", force: :cascade do |t|
    t.integer  "datatable_id"
    t.string   "title",        limit: 255
    t.text     "body"
    t.text     "query"
    t.string   "graph_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "x_axis_label", limit: 255
    t.string   "y_axis_label", limit: 255
    t.integer  "weight"
  end

  create_table "websites", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "data_catalog_intro"
    t.text     "url"
  end

  add_foreign_key "affiliations", "people", name: "affiliations_person_id_fkey"
  add_foreign_key "affiliations", "roles", name: "affiliations_role_id_fkey1"
  add_foreign_key "authors", "citations", name: "authors_citation_id_fk"
  add_foreign_key "authors", "citations", name: "authors_citation_id_fkey"
  add_foreign_key "datatables", "datasets", name: "datatables_dataset_id_fkey", on_update: :restrict, on_delete: :restrict
  add_foreign_key "editors", "citations", name: "editors_citation_id_fk"
  add_foreign_key "editors", "citations", name: "editors_citation_id_fkey"
  add_foreign_key "variates", "datatables", name: "variates_datatable_id_fkey"
  add_foreign_key "variates", "units", name: "variates_unit_id_fkey"
end
