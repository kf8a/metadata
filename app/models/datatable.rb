# encoding: UTF-8

require 'rexml/document'
require 'csv'
require 'eml'
include REXML

class Datatable < ActiveRecord::Base
  attr_protected :object
  attr_accessor :materialized_datatable_id

  acts_as_taggable_on :keywords

  has_and_belongs_to_many :citations
  has_one                 :collection
  has_and_belongs_to_many :core_areas
  belongs_to              :dataset
  has_many                :data_contributions
  has_many                :owners, :through => :ownerships, :source => :user
  has_many                :ownerships
  has_many                :people, :through => :data_contributions
  has_many                :permission_requests
  has_many                :permissions
  has_many                :requesters, :through => :permission_requests, :source => :user
  has_and_belongs_to_many :protocols
  belongs_to              :study
  belongs_to              :theme
  has_many                :variates, :order => :weight
  has_many                :visualizations, :order => :weight

  validates :title,   :presence => true
  validates :dataset, :presence => true
  validates_uniqueness_of :name

  accepts_nested_attributes_for :data_contributions, :allow_destroy => true
  accepts_nested_attributes_for :variates, :allow_destroy => true

  scope :by_name, :order => 'name'

  if Rails.env.production?
    has_attached_file :csv_cache,
        :storage => :s3,
        :bucket => 'metadata_production',
        :path => "/datatables/csv/:id.:extension",
        :s3_credentials => File.join(Rails.root, 'config', 's3.yml'),
        :s3_permissions => 'authenticated-read'
  else
    has_attached_file :csv_cache, :url => "/datatables/:id/download",
        :path => ":rails_root/uploads/datatables/:attachment/:id.:extension"
  end

  include Workflow

  workflow do
    state :active do
      event :complete,      :transitions_to => :completed
      event :mark_deleted,  :transitions_to => :deleted
    end
    state :completed do
      event :revert,        :transitions_to => :active
      event :mark_deleted,  :transitions_to => :deleted
    end
    state :deleted do
      event :revert,        :transitions_to => :active
    end
  end

  def revert
    self.completed_on = nil
    save
  end

  def complete
    self.completed_on = Date.today
    save
  end

  define_index do
    indexes title
    indexes description
    indexes theme.name, :as => :theme
    indexes data_contributions.person.sur_name, :as => :datatable_sur_name
    indexes data_contributions.person.given_name, :as => :datatable_given_name
    indexes dataset.affiliations.person.sur_name, :as => :sur_name
    indexes dataset.affiliations.person.given_name, :as => :given_name
    indexes taggings.tag.name, :as => :keyword_name
    indexes dataset.title, :as => :dataset_title
    indexes dataset.dataset, :as => :dataset_identifier
    indexes core_areas.name, :as  => :core_area
    indexes name
    has dataset.website_id, :as => :website
    where "datatables.on_web is true and datasets.on_web"

    #set_property :field_weights => {:keyword => 20, :theme => 20, :title => 10}
  end

  def self.from_eml(datatable_eml)
    url = datatable_eml.css('physical distribution online url').text
    table_id = url.split('/')[-1].to_s.gsub('.csv', '')
    find_by_id(table_id.to_i) || new.from_eml(datatable_eml)
  end

  def from_eml(datatable_eml)
    self.name = datatable_eml.attributes['id'].try(:value)
    self.title = datatable_eml.css('entityName').text
    self.description = datatable_eml.css('entityDescription').text
    self.data_url = datatable_eml.css('physical distribution online url').text
    associated_models_from_eml(datatable_eml)
    self.save

    self
  end

  def associated_models_from_eml(datatable_eml)
    datatable_eml.css('methods methodStep').each do |protocol_eml|
      protocol_id = protocol_eml.css('protocol references').text.gsub('protocol_', '')
      self.protocols << Protocol.where(:id => protocol_id)
    end

    datatable_eml.css('attributeList attribute').each do |variate_eml|
      self.variates << Variate.from_eml(variate_eml)
    end
  end

  def valid_for_eml?
    valid_variates.any?
  end

  def valid_variates
    self.variates.valid_for_eml
  end

  def protocols_with_backup
    protocols.presence || dataset.protocols.presence
  end

  def to_label
    "#{title} (#{name})"
  end

  def personnel
    datatable_personnel.presence || dataset_personnel
  end

  def datatable_personnel
    compile_personnel(data_contributions)
  end

  def dataset_personnel
    compile_personnel(dataset.affiliations)
  end

  def compile_personnel(source, personnel={})
    source.each do |contribution|
      if personnel[contribution.person]
        personnel[contribution.person].push((contribution.role.name))
      else
        personnel[contribution.person] = [contribution.role.name]
      end
    end
    personnel
  end

  def which_roles(person)
    data_contributions.collect {|affiliation | affiliation.role if affiliation.person == person }.compact
  end

  def leads
    lead_investigator = Role.find_by_name('lead investigator')
    data_contributions.collect { |affiliation| affiliation.person if affiliation.role == lead_investigator }.compact
  end


  def keyword_names
    keywords.collect {|x| x.name}
  end
  def related_keywords
    #http://vocab.lternet.edu/webservice/keywordlist.php/all/csv
    agent = Mechanize.new
    keywords.collect do |keyword|
      terms = agent.get("http://vocab.lternet.edu/webservice/keywordlist.php/all/csv/#{keyword}")
      CSV.parse(terms)
    end.flatten.sort.uniq
  end

  # publishing
  def publish
    begin
      file = Tempfile.new('csv_cache')
      file << self.approved_csv
      self.csv_cache = file
      self.csv_cache_file_name = "#{id}.csv"
      self.csv_cache_content_type = 'text/csv'
      save!
    ensure
      file.close
      file.unlink
    end
  end

  def retract
    csv_cache.destroy
    save
  end

  def restricted_to_members?
    dataset.restricted_to_members?
  end

  def permitted?(user)
    user.present? && owners.present? && owners.all? do |owner|
      user.has_permission_from?(owner, self)
    end
  end

  def pending_requesters
    requesters.collect { |user| user unless self.permitted?(user) }.compact
  end

  def requested_by?(user)
    requesters.include?(user)
  end

  def deniers_of(user)
    permissions.where(:user_id => user, :decision => 'denied').collect(&:owner)
  end

  def sponsor
    dataset.sponsor
  end

  def sponsor_name
    sponsor.name
  end

  def can_be_qcd_by?(user)
    if sponsor_name == 'lter'
      user.try(:admin?) || member?(user)
    elsif sponsor_name == 'glbrc'
      user.try(:admin?) || owned_by?(user)
    else
      false
    end
  end

  def can_be_downloaded_by?(user)
    if self.is_restricted
      user.try(:admin?) ||
      permitted?(user) ||
      owned_by?(user)
    elsif restricted_to_members?
      user.try(:admin?) ||
      permitted?(user) ||
      owned_by?(user) ||
      member?(user)
    else
      true
    end
  end

  def owned_by?(user)
    owners.include?(user)
  end

  def member?(user)
    sponsors = user.try(:sponsors).to_a
    sponsors.include?(self.dataset.try(:sponsor))
  end

  def within_interval?(start_date, end_date)
    extent = temporal_extent

    extent[:begin_date] &&
        extent[:begin_date] >= start_date && extent[:end_date] <= end_date
  end

  def title_and_years
    return title if (self.begin_date.nil? or self.end_date.nil?)
    year_end = end_date.year
    year_start = begin_date.year
    years = ""
    if year_end == year_start
        years = " (#{year_start})"
    else
        years = " (#{year_start} to #{ ongoing? ? 'present': year_end})"
    end
    title + years
  end

  def ongoing?
    return false if self.completed?
    next_expected_update = update_frequency_days.present? ? update_frequency_days : 365
    expected_update = end_date.year + next_expected_update/265 + 2
    expected_update > Time.now.year
  end

  def non_dataset_protocols
    protocols.reject { |protocol| dataset.protocols.include?(protocol) }.compact
  end

  def to_eml(xml = ::Builder::XmlMarkup.new)
    @eml = xml
    @eml.dataTable 'id' => Rails.application.routes.url_helpers.datatable_path(self) do
      @eml.entityName "Kellogg Biological Station LTER: #{title} (#{name#}"
      if description
        text =  description.gsub(/<\/?[^>]*>/, "")
        @eml.entityDescription EML.text_sanitize(text) unless text.strip.empty?
      end
#      eml_protocols if non_dataset_protocols.present?
      eml_physical
      eml_attributes
    end
  end

  def raw_csv(units=true)
    convert_to_csv(all_data, units)
  end

  def approved_csv
    convert_to_csv(approved_data)
  end

  def variate_names
    variates.collect {|variate| variate.try(:name)}
  end

  def variate_units
    units = variates.collect {|variate| variate.unit.name if variate.unit }
    units[0] = "##{units[0]}"
    units
  end

  def completed
    dataset.try(:completed)
  end

  def status
    if workflow_state
      workflow_state
    else
      dataset.try(:status)
    end
  end


  def convert_to_csv(values, units=true)
    csv_string = CSV.generate do |csv|
      vars = variate_names
      csv << vars
      if units
        csv << variate_units
      end
      fields = values.fields
      unless fields.join(' ') =~ /[A-Z]/
        vars =  variates.collect {|variate| variate.name.downcase }
      end
      values.each do |row|
        csv << vars.collect { |variate| row[variate] }
      end
    end
    csv_string
  end

  def to_csv
    # stupid microsofts
    csv_string = approved_csv.force_encoding("UTF-8")
    result = ""
    header + csv_string
  end

  def header
    terms_of_use + data_source +  data_comments + "#\n#\n"
  end

  def to_climdb
    "!#{raw_csv(false)}" # no units
  end

  def terms_of_use
    <<-END
# These Data are copyrighted and use in a publication requires permission
# as detailed in our Terms of use:  http://lter.kbs.msu.edu/data/terms-of-use/
#
  END
  end

  def data_comments
    if comments
      "#\n#        DATATABLE CORRECTIONS AND COMMENTS\n" + comments.gsub(/^/,'#') + "\n"
    else
      "\n#"
    end
  end

  def data_source
    <<-END
# Data Source: http://#{website_name}.kbs.msu.edu/datatables/#{self.id}
# The newest version of the data http://#{website_name}.kbs.msu.edu/datatables/#{self.id}.csv
# Full EML Metadata: http://#{website_name}.kbs.msu.edu/datatables/#{self.dataset.id}.eml
# 
    END
  end

  def database_date_field
    values = ActiveRecord::Base.connection.execute(object)
    case
      when values.fields.member?('sample_date') then 'sample_date'
      when values.fields.member?('obs_date') then 'obs_date'
      when values.fields.member?('date') then 'date'
      when values.fields.member?('datetime') then 'datetime'
      when values.fields.member?('year') then 'year'
      when values.fields.member?('harvest_date') then 'harvest_date'
    end
  end

  def temporal_extent
    data_start_date = data_end_date = nil
    if is_sql
      date_field = database_date_field
      if date_field
        query = "select max(#{date_field}), min(#{date_field}) from (#{object}) as t1"
        data_start_date, data_end_date = query_datatable_for_temporal_extent(query)
      end
    end
    {:begin_date => data_start_date,:end_date => data_end_date}
  end

  def update_temporal_extent
    dates = temporal_extent
    self.begin_date = dates[:begin_date] if dates[:begin_date]
    self.end_date = dates[:end_date] if dates[:end_date]
    save
    dataset.update_temporal_extent
  end

  def data_preview
    unless @data_preview
      limit = self.excerpt_limit || 5
      query = "#{self.object}  offset #{offset} limit #{limit}"
      @data_preview = ActiveRecord::Base.connection.execute(query)
    end
    @data_preview
  end

  def approved_data_query
    query = self.object
    if self.number_of_released_records
      query = query + " offset #{offset}"
    end
    query
  end

  def approved_data
    ActiveRecord::Base.connection.execute(approved_data_query)
  end

  def all_data
    ActiveRecord::Base.connection.execute(self.object)
  end

  def get_csv_data(query)
    result = ActiveRecord::Base.connection.execute(query + 'limit 0')
  end

  def offset
    self.number_of_released_records ||= total_records
    result = total_records - number_of_released_records
    result < 0 ? 0 :result
  end

  def total_records
    unless @total_records
      query = "select count(*) as count from (#{self.object}) as t1"
      result = ActiveRecord::Base.connection.execute(query).first
      @total_records = result['count'].to_i
    end
    @total_records
  end

  def approve_data
    self.number_of_released_records = total_records
  end

  def perform_query
    query =  self.object
    ActiveRecord::Base.connection.execute(query)
  end

  def related_tables
    self.dataset.datatables - [self]
  end

  def related_files
    self.dataset.dataset_files
  end

  def sponsor_name
    dataset.sponsor.try(:name) || 'lter'
  end

  def website_name
    dataset.website.try(:name) || 'lter'
  end

  def study_link_for(website)
    study.try(:study_url, website)
  end

  def study_name
    study.try(:name).to_s
  end

  def values
    values = nil
    values = self.perform_query if self.is_sql
  end

  def number_of_header_lines
    header.lines.to_a.size + 3
  end

  # a datatable should not be superceded by itself
  def supercession_candidates
    Datatables.where('id <> ?', id).all
  end


  ## Utilites

  private

  def query_datatable_for_temporal_extent(query)
    values = ActiveRecord::Base.connection.execute(query)
    dates = values[0]
    min, max = dates['min'], dates['max']
    if min.length == 4  # assume is a year
      min = min + '-1-1'
    end
    if max.length == 4
      max = max + '-1-1'
    end

    [Time.parse(min).to_date, Time.parse(max).to_date]
  end

  def eml_protocols
    # @eml.methods do
    #   non_dataset_protocols.each { |protocol| protocol.to_eml_ref(@eml) }
    # end
  end

  def eml_data_format
    @eml.dataFormat do
      @eml.textFormat do
        @eml.numHeaderLines number_of_header_lines.to_s
        @eml.numFooterLines 1
        @eml.recordDelimiter '\n'
        @eml.attributeOrientation 'column'
        @eml.simpleDelimited do
          @eml.fieldDelimiter ','
          @eml.collapseDelimiters 'no'
          @eml.quoteCharacter '"'
          @eml.literalCharacter '\\'
        end
      end
    end
  end

  def eml_physical
    @eml.physical do
      @eml.objectName title
      @eml.encodingMethod "None"
      eml_data_format
      @eml.distribution do
        @eml.online do
          if is_sql
            @eml.url "http://#{website_name}.kbs.msu.edu/datatables/#{self.id}.csv"
          else
            @eml.url data_url
          end
        end
      end
    end
  end

  def eml_attributes
    @eml.attributeList do
      valid_variates.each do |variate|
        variate.to_eml(@eml)
      end
    end
  end

end



# == Schema Information
#
# Table name: datatables
#
#  id                         :integer         not null, primary key
#  name                       :string(255)
#  title                      :string(255)
#  comments                   :text
#  dataset_id                 :integer
#  data_url                   :string(255)
#  connection_url             :string(255)
#  driver                     :string(255)
#  is_restricted              :boolean
#  description                :text
#  object                     :text
#  metadata_url               :string(255)
#  is_sql                     :boolean
#  update_frequency_days      :integer
#  last_updated_on            :date
#  access_statement           :text
#  excerpt_limit              :integer
#  begin_date                 :date
#  end_date                   :date
#  on_web                     :boolean         default(TRUE)
#  theme_id                   :integer
#  core_area_id               :integer
#  weight                     :integer         default(100)
#  study_id                   :integer
#  created_at                 :datetime
#  updated_at                 :datetime
#  is_secondary               :boolean         default(FALSE)
#  is_utf_8                   :boolean         default(FALSE)
#  metadata_only              :boolean         default(FALSE)
#  summary_graph              :text
#  event_query                :text
#  deprecated_in_fovor_of     :integer
#  deprecation_notice         :text
#  number_of_released_records :integer
#
