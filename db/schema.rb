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
  enable_extension "plpgsql"

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
    t.string "title"
    t.string "supervisor"
    t.date "started_on"
    t.date "left_on"
    t.string "research_interest"
    t.index ["dataset_id"], name: "index_affiliations_on_dataset_id"
    t.index ["person_id"], name: "index_affiliations_on_person_id"
    t.index ["role_id"], name: "index_affiliations_on_role_id"
  end

  create_table "authors", id: :serial, force: :cascade do |t|
    t.string "sur_name"
    t.string "given_name"
    t.string "middle_name"
    t.integer "seniority"
    t.integer "person_id"
    t.integer "citation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "suffix"
    t.index ["citation_id"], name: "index_authors_on_citation_id"
    t.index ["person_id"], name: "index_authors_on_person_id"
  end

  create_table "citation_types", id: :serial, force: :cascade do |t|
    t.string "abbreviation"
    t.string "name"
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
    t.string "publication"
    t.string "start_page_number"
    t.string "ending_page_number"
    t.text "periodical_full_name"
    t.string "periodical_abbreviation"
    t.string "volume"
    t.string "issue"
    t.string "city"
    t.string "publisher"
    t.string "secondary_title"
    t.string "series_title"
    t.string "isbn"
    t.string "doi"
    t.text "full_text"
    t.string "publisher_url"
    t.integer "website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "pdf_file_name"
    t.string "pdf_content_type"
    t.integer "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.string "state"
    t.string "type"
    t.boolean "open_access", default: false
    t.boolean "has_lter_acknowledgement"
    t.string "annotation"
    t.string "data_url"
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

  create_table "core_areas", id: :serial, force: :cascade do |t|
    t.string "name"
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

  create_table "dataset_dois", id: :serial, force: :cascade do |t|
    t.integer "dataset_id"
    t.string "doi"
    t.integer "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dataset_files", id: :serial, force: :cascade do |t|
    t.text "name"
    t.integer "dataset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "datasets", id: :serial, force: :cascade do |t|
    t.string "dataset"
    t.string "title"
    t.text "abstract"
    t.string "old_keywords"
    t.string "status"
    t.date "initiated"
    t.date "completed"
    t.date "released"
    t.boolean "on_web", default: true
    t.integer "version"
    t.boolean "core_dataset", default: false
    t.integer "project_id"
    t.integer "metacat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sponsor_id"
    t.integer "website_id"
    t.date "data_end_date"
    t.float "west_bounding_coordinate"
    t.float "east_bounding_coordinate"
    t.float "north_bounding_coordinate"
    t.float "south_bounding_coordinate"
    t.boolean "cc0"
    t.index ["metacat_id"], name: "index_datasets_on_metacat_id"
    t.index ["project_id"], name: "index_datasets_on_project_id"
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
    t.string "name"
    t.string "title"
    t.text "comments"
    t.integer "dataset_id"
    t.string "data_url"
    t.string "connection_url"
    t.string "driver"
    t.boolean "is_restricted"
    t.text "description"
    t.string "object"
    t.string "metadata_url"
    t.boolean "is_sql"
    t.integer "update_frequency_days"
    t.date "last_updated_on"
    t.integer "excerpt_limit"
    t.date "begin_date"
    t.date "end_date"
    t.boolean "on_web", default: true
    t.integer "theme_id"
    t.integer "core_area_id"
    t.integer "weight", default: 100
    t.integer "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_secondary", default: false
    t.boolean "is_utf_8", default: false
    t.boolean "metadata_only", default: false
    t.text "summary_graph"
    t.integer "deprecated_in_favor_of"
    t.text "deprecation_notice"
    t.integer "number_of_released_records"
    t.text "access_statement"
    t.text "scores"
    t.date "completed_on"
    t.text "workflow_state"
    t.integer "update_cache_days"
    t.integer "sponsor_id"
    t.index ["core_area_id"], name: "index_datatables_on_core_area_id"
    t.index ["dataset_id"], name: "index_datatables_on_dataset_id"
    t.index ["study_id"], name: "index_datatables_on_study_id"
    t.index ["theme_id"], name: "index_datatables_on_theme_id"
  end

  create_table "datatables_protocols", id: false, force: :cascade do |t|
    t.integer "datatable_id"
    t.integer "protocol_id"
    t.index ["datatable_id"], name: "index_datatables_protocols_on_datatable_id"
    t.index ["protocol_id"], name: "index_datatables_protocols_on_protocol_id"
  end

  create_table "datatables_variates", id: :serial, force: :cascade do |t|
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.string "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "editors", id: :serial, force: :cascade do |t|
    t.string "sur_name"
    t.string "given_name"
    t.string "middle_name"
    t.integer "seniority"
    t.integer "person_id"
    t.integer "citation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "suffix"
  end

  create_table "eml_docs", id: :serial, force: :cascade do |t|
  end

  create_table "invites", id: :serial, force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "email"
    t.string "invite_code", limit: 40
    t.datetime "invited_at"
    t.datetime "redeemed_at"
    t.boolean "glbrc_member"
    t.index ["id", "email"], name: "index_invites_on_id_and_email"
    t.index ["id", "invite_code"], name: "index_invites_on_id_and_invite_code"
  end

  create_table "measurement_scales", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "meeting_abstract_types", id: :serial, force: :cascade do |t|
    t.text "name"
    t.integer "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "meeting_abstracts", id: :serial, force: :cascade do |t|
    t.text "title"
    t.text "authors"
    t.text "abstract"
    t.integer "meeting_id"
    t.string "pdf_file_name"
    t.string "pdf_content_type"
    t.integer "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.text "author_affiliations"
    t.integer "meeting_abstract_type_id"
    t.index ["meeting_id"], name: "index_meeting_abstracts_on_meeting_id"
  end

  create_table "meetings", id: :serial, force: :cascade do |t|
    t.date "date"
    t.string "title"
    t.text "announcement"
    t.integer "venue_type_id"
    t.date "date_to"
    t.index ["venue_type_id"], name: "index_meetings_on_venue_type_id"
  end

  create_table "memberships", id: :serial, force: :cascade do |t|
    t.integer "sponsor_id"
    t.integer "user_id"
  end

  create_table "open_id_authentication_associations", id: :serial, force: :cascade do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string "handle"
    t.string "assoc_type"
    t.binary "server_url"
    t.binary "secret"
  end

  create_table "open_id_authentication_nonces", id: :serial, force: :cascade do |t|
    t.integer "timestamp", null: false
    t.string "server_url"
    t.string "salt", null: false
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
    t.string "title"
    t.string "attribution"
    t.integer "page_id"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.index ["page_id"], name: "index_page_images_on_page_id"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.string "person"
    t.string "sur_name"
    t.string "given_name"
    t.string "middle_name"
    t.string "friendly_name"
    t.string "title"
    t.string "sub_organization"
    t.string "organization"
    t.string "street_address"
    t.string "city"
    t.string "locale"
    t.string "country"
    t.string "postal_code"
    t.string "phone"
    t.string "fax"
    t.string "email"
    t.string "url"
    t.boolean "deceased"
    t.string "open_id"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.string "orcid"
    t.string "orcid_id"
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
    t.string "decision"
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

  create_table "plots", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "treatment_id"
    t.integer "replicate"
    t.integer "study_id"
    t.string "description"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "abstract"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "funder_name"
    t.string "funder_identifier"
    t.string "award_number"
    t.string "award_url"
  end

  create_table "protocols", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.integer "version_tag"
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
    t.string "pdf_file_name"
    t.string "pdf_content_type"
    t.integer "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["dataset_id"], name: "index_protocols_on_dataset_id"
    t.index ["person_id"], name: "index_protocols_on_person_id"
  end

  create_table "protocols_websites", id: false, force: :cascade do |t|
    t.integer "protocol_id"
    t.integer "website_id"
    t.index ["protocol_id"], name: "index_protocols_websites_on_protocol_id"
    t.index ["website_id"], name: "index_protocols_websites_on_website_id"
  end

  create_table "publications", id: :serial, force: :cascade do |t|
    t.integer "publication_type_id"
    t.text "citation"
    t.text "abstract"
    t.integer "year"
    t.string "authors"
    t.string "title"
    t.string "file_url"
    t.integer "source_id"
    t.integer "parent_id"
    t.string "content_type"
    t.string "filename"
    t.integer "size"
    t.integer "width"
    t.integer "height"
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

  create_table "role_types", id: :serial, force: :cascade do |t|
    t.string "name"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name"
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
    t.string "session_id"
    t.text "data"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "slugs", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "sluggable_id"
    t.integer "sequence", default: 1, null: false
    t.string "sluggable_type", limit: 40
    t.string "scope"
    t.datetime "created_at"
    t.index ["name", "sluggable_type", "sequence", "scope"], name: "index_slugs_on_n_s_s_and_s", unique: true
    t.index ["sluggable_id"], name: "index_slugs_on_sluggable_id"
  end

  create_table "sources", id: :serial, force: :cascade do |t|
    t.string "title"
  end

  create_table "species", id: :serial, force: :cascade do |t|
    t.string "species"
    t.string "genus"
    t.string "family"
    t.string "code"
    t.string "common_name"
    t.string "alternate_common_name"
    t.string "attribution"
    t.boolean "woody"
  end

  create_table "sponsors", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "data_restricted", default: false
    t.text "data_use_statement"
    t.string "terms_of_use_url"
  end

  create_table "studies", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "weight"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.text "synopsis"
    t.string "url"
    t.text "warning"
    t.text "source"
    t.text "old_names"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["parent_id"], name: "index_studies_on_parent_id"
  end

  create_table "study_urls", id: :serial, force: :cascade do |t|
    t.integer "website_id"
    t.integer "study_id"
    t.string "url"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "taggable_type"
    t.string "context"
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "templates", id: :serial, force: :cascade do |t|
    t.integer "website_id"
    t.string "controller"
    t.string "action"
    t.text "layout"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["website_id"], name: "index_templates_on_website_id"
  end

  create_table "themes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "weight"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["parent_id"], name: "index_themes_on_parent_id"
  end

  create_table "treatments", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "study_id"
    t.integer "weight"
    t.boolean "use_in_citations", default: true
    t.index ["study_id"], name: "index_treatments_on_study_id"
  end

  create_table "units", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "in_eml", default: false
    t.text "definition"
    t.integer "deprecated_in_favor_of"
    t.string "unit_type"
    t.string "parent_si"
    t.float "multiplier_to_si"
    t.string "label"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password", limit: 128
    t.string "salt", limit: 128
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128
    t.boolean "email_confirmed", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "identity_url"
    t.string "role"
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
    t.index ["id", "confirmation_token"], name: "index_users_on_id_and_confirmation_token"
    t.index ["identity_url"], name: "index_users_on_identity_url", unique: true
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  create_table "variates", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "datatable_id"
    t.integer "weight"
    t.text "description"
    t.string "missing_value_indicator"
    t.integer "unit_id"
    t.string "measurement_scale"
    t.string "data_type"
    t.float "min_valid"
    t.float "max_valid"
    t.float "precision"
    t.string "date_format"
    t.index ["datatable_id"], name: "index_variates_on_datatable_id"
    t.index ["unit_id"], name: "index_variates_on_unit_id"
  end

  create_table "venue_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "versioned_type"
    t.integer "versioned_id"
    t.string "user_type"
    t.integer "user_id"
    t.string "user_name"
    t.text "modifications"
    t.integer "number"
    t.integer "reverted_from"
    t.string "tag"
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
    t.string "title"
    t.text "body"
    t.text "query"
    t.string "graph_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "x_axis_label"
    t.string "y_axis_label"
    t.integer "weight"
  end

  create_table "websites", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "data_catalog_intro"
    t.text "url"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "authors", "citations"
  add_foreign_key "editors", "citations"
end
