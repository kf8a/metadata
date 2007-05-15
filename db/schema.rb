# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 30) do

  create_table "affiliations", :force => true do |t|
    t.column "person_id",  :integer
    t.column "role_id",    :integer
    t.column "dataset_id", :integer
    t.column "seniority",  :integer
  end

  create_table "datasets", :force => true do |t|
    t.column "dataset",      :string
    t.column "title",        :string
    t.column "abstract",     :text
    t.column "keywords",     :string
    t.column "status",       :string
    t.column "initiated",    :date
    t.column "completed",    :date
    t.column "released",     :date
    t.column "on_web",       :boolean, :default => true
    t.column "version",      :integer
    t.column "core_dataset", :boolean, :default => false
  end

  create_table "datasets_themes", :id => false, :force => true do |t|
    t.column "theme_id",   :integer
    t.column "dataset_id", :integer
  end

  create_table "datatables", :force => true do |t|
    t.column "name",           :string
    t.column "title",          :string
    t.column "comments",       :text
    t.column "dataset_id",     :integer
    t.column "data_url",       :string
    t.column "connection_url", :string
    t.column "driver",         :string
    t.column "is_restricted",  :boolean
    t.column "description",    :text
    t.column "object",         :string
    t.column "metadata_url",   :string
  end

  create_table "eml_docs", :force => true do |t|
  end

  create_table "meeting_abstracts", :force => true do |t|
    t.column "title",      :string
    t.column "authors",    :string
    t.column "abstract",   :text
    t.column "meeting_id", :integer
  end

  create_table "meetings", :force => true do |t|
    t.column "date",          :date
    t.column "title",         :string
    t.column "announcement",  :text
    t.column "venue_type_id", :integer
    t.column "date_to",       :date
  end

  create_table "open_id_associations", :force => true do |t|
    t.column "server_url", :binary
    t.column "handle",     :string
    t.column "secret",     :binary
    t.column "issued",     :integer
    t.column "lifetime",   :integer
    t.column "assoc_type", :string
  end

  create_table "open_id_nonces", :force => true do |t|
    t.column "nonce",   :string
    t.column "created", :integer
  end

  create_table "open_id_settings", :force => true do |t|
    t.column "setting", :string
    t.column "value",   :binary
  end

  create_table "people", :force => true do |t|
    t.column "person",           :string
    t.column "sur_name",         :string
    t.column "given_name",       :string
    t.column "middle_name",      :string
    t.column "friendly_name",    :string
    t.column "title",            :string
    t.column "sub_organization", :string
    t.column "organization",     :string
    t.column "street_address",   :string
    t.column "city",             :string
    t.column "locale",           :string
    t.column "country",          :string
    t.column "postal_code",      :string
    t.column "phone",            :string
    t.column "fax",              :string
    t.column "email",            :string
    t.column "url",              :string
    t.column "deceased",         :boolean
    t.column "open_id",          :string
  end

  create_table "protocols", :force => true do |t|
    t.column "name",           :string
    t.column "title",          :string
    t.column "version",        :integer
    t.column "in_use_from",    :date
    t.column "in_use_to",      :date
    t.column "description",    :text
    t.column "abstract",       :text
    t.column "body",           :text
    t.column "person_id",      :integer
    t.column "created_on",     :date
    t.column "updated_on",     :date
    t.column "change_summary", :text
    t.column "dataset_id",     :integer
    t.column "active",         :boolean, :default => true
  end

  create_table "publication_types", :force => true do |t|
    t.column "name", :string
  end

  create_table "publications", :force => true do |t|
    t.column "publication_type_id", :integer
    t.column "citation",            :text
    t.column "abstract",            :text
    t.column "year",                :integer
    t.column "file_url",            :string
    t.column "title",               :text
    t.column "authors",             :text
    t.column "source_id",           :integer
  end

  create_table "role_types", :force => true do |t|
    t.column "name", :string
  end

  create_table "roles", :force => true do |t|
    t.column "name",         :string
    t.column "role_type_id", :integer
    t.column "seniority",    :integer
  end

  create_table "sessions", :force => true do |t|
    t.column "session_id", :string
    t.column "data",       :text
    t.column "updated_at", :datetime
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sources", :force => true do |t|
    t.column "title", :string
  end

  create_table "themes", :force => true do |t|
    t.column "title",    :string
    t.column "priority", :integer
  end

  create_table "units", :force => true do |t|
    t.column "name",        :string
    t.column "description", :text
    t.column "in_eml",      :boolean, :default => false
    t.column "definition",  :text
  end

  add_index "units", ["name"], :name => "unit_names_key", :unique => true

  create_table "variates", :force => true do |t|
    t.column "name",                    :string
    t.column "datatable_id",            :integer
    t.column "position",                :integer
    t.column "description",             :text
    t.column "missing_value_indicator", :string
    t.column "unit_id",                 :integer
    t.column "measurement_scale",       :string
    t.column "data_type",               :string
    t.column "min_valid",               :float
    t.column "max_valid",               :float
    t.column "date_format",             :string
    t.column "precision",               :float
  end

  create_table "venue_types", :force => true do |t|
    t.column "name", :string
  end

end
