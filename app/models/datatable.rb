# encoding: UTF-8

require 'rexml/document'
require 'csv'
require 'iconv'
include REXML

class Datatable < ActiveRecord::Base
  attr_protected :object
  attr_accessor :materialized_datatable_id

  acts_as_taggable_on :keywords

  has_and_belongs_to_many :citations
  has_one                 :collection
  belongs_to              :core_area
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
  has_many                :visualizations

  validates :title,   :presence => true
  validates :dataset, :presence => true

  accepts_nested_attributes_for :data_contributions, :allow_destroy => true
  accepts_nested_attributes_for :variates, :allow_destroy => true

  scope :by_name, :order => 'name'

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
    indexes name
    has dataset.website_id, :as => :website
    where "datatables.on_web is true and datasets.on_web"

    #set_property :field_weights => {:keyword => 20, :theme => 20, :title => 10}
  end

  def self.from_eml(datatable_eml)
    table_id = datatable_eml.css('physical distribution online url').text.split('/')[-1].gsub('.csv', '')
    table = Datatable.find_by_id(table_id.to_i)
    unless table.present?
      table = Datatable.new
      table.name = datatable_eml.attributes['id'].value
      table.title = datatable_eml.css('entityName').text
      table.description = datatable_eml.css('entityDescription').text
      table.data_url = datatable_eml.css('physical distribution online url').text
      datatable_eml.css('methods methodStep').each do |protocol_eml|
        protocol_id = protocol_eml.css('protocol references').text.gsub('protocol_', '')
        protocol = Protocol.find_by_id(protocol_id)
        table.protocols << protocol if protocol.present?
      end

      datatable_eml.css('attributeList attribute').each do |variate_eml|
        variate_name = variate_eml.css('attributeName').text
        variate = Variate.find_by_name(variate_name)
        if variate.present?
          table.variates << variate
        else
          variate = Variate.new
          variate.name = variate_name
          variate.description = variate_eml.css('attributeDefinition').text
          #TODO add the scale
          variate.save
          table.variates << variate
        end
      end

      table.save
    end

    table
  end

  def valid_for_eml
    valid_variates.present?
  end

  def valid_variates
    self.variates.keep_if {|variate| variate.valid_for_eml}
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

  def related_keywords
    #http://vocab.lternet.edu/webservice/keywordlist.php/all/csv
    agent = Mechanize.new
    keywords.collect do |keyword|
      terms = agent.get("http://vocab.lternet.edu/webservice/keywordlist.php/all/csv/#{keyword}")
      CSV.parse(terms)
    end.flatten.sort.uniq
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

  def events
    event_query_sql = event_query || ""
    values  = ActiveRecord::Base.connection.execute(event_query_sql)

    events = values.collect do |value|
      {'start' => Date.parse(value['date']).rfc2822,
        'title' => value['title'],
        'description' => value['description'],
        'durationEvent' => false }
    end

    event_summary = events.inject do |event|

    end
    {'dateTimeFormat'=> 'Gregorian', 'events'=> events}.to_json
  end

  #TODO create a completed flag and use the actual end year if present
  def title_and_years
    return title if (self.begin_date.nil? or self.end_date.nil?)
    year_end = end_date.year
    year_start = begin_date.year
    reply = ""
    if year_end == year_start
      reply = " (#{year_start})"
    else
      reply = " (#{year_start} to #{ year_end > Time.now.year - 3 ? 'present': year_end})"
    end
    title + reply
  end

  def non_dataset_protocols
    protocols.reject { |protocol| dataset.protocols.include?(protocol) }.compact
  end

  def to_eml(xml = Builder::XmlMarkup.new)
    @eml = xml
    @eml.dataTable 'id' => name do
      @eml.entityName title
      @eml.entityDescription description.gsub(/<\/?[^>]*>/, "")
      eml_protocols if non_dataset_protocols.present?
      eml_physical
      eml_attributes
    end
  end

  def raw_csv
    values  = approved_data
    csv_string = CSV.generate do |csv|
      csv << variates.collect { |variate| variate.name }
      values.each do |row|
        csv << variates.collect do |variate|
          row[variate.name.downcase]
        end
      end
    end
    csv_string
  end

  def to_csv
    # stupid microsofts
    csv_string = raw_csv.force_encoding("UTF-8")
    result = ""
    result = data_access_statement + data_source + data_comments + csv_string
    if is_utf_8
      result = Iconv.conv('utf-16','utf-8', result)
    end
    result
  end

  def to_climdb
    "!#{raw_csv}"
  end

  def data_comments
    comments ?  comments.gsub(/^/,'#') + "\n" : ''
  end

  def data_source
    "\n# Data Source: http://#{website_name}.kbs.msu.edu/datatables/#{self.id}
# The newest version of the data http://#{website_name}.kbs.msu.edu/datatables/#{self.id}.csv
# Full EML Metadata: http://#{website_name}.kbs.msu.edu/datatables/#{self.dataset.id}.eml\n#"
  end

  def data_access_statement
    access_statement = dataset.sponsor.try(:data_use_statement)
    if access_statement
      access_statement.gsub(/.{1,60}(?:\s|\Z)/){($& + 5.chr)\
            .gsub(/\n\005/,"\n")\
            .gsub(/\005/,"\n")}\
          .split(/\n/)\
          .collect {|line| "# #{line}\n"}\
          .join
    else
      ''
    end
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
      unless date_field.nil?
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
  end

  def data_preview
    query =  self.object
    self.excerpt_limit = 5 unless self.excerpt_limit
    query = query + " limit #{self.excerpt_limit}"
    ActiveRecord::Base.connection.execute(query)
  end

  def approved_data
    query = self.object
    self.number_of_released_records ||= total_records
    query = query + " offset #{total_records - self.number_of_released_records}"
    ActiveRecord::Base.connection.execute(query)
  end

  def total_records
    values.count
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

  # a datatable should not be superceded by itself
  def supercession_candidates
    Datatables.where('id <> ?', id).all
  end


  ## Utilites

  #migrate dataset personel to datatables
  def migrate_personel!
    if data_contributions.empty?
      dataset.affiliations.each do |affiliation|
        contribution = DataContribution.new
        contribution.person = affiliation.person
        contribution.role = affiliation.role
        contribution.seniority = affiliation.seniority

        data_contributions << contribution
      end
    end
  end

  private

  def query_datatable_for_temporal_extent(query)
    values = ActiveRecord::Base.connection.execute(query)
    dates = values[0]
    min, max = dates['min'], dates['max']
    unless dates.class == 'Date' # assume is a year
      min = min.to_s + '-1-1'
      max = max.to_s + '-1-1'
    end

    [Time.parse(min).to_date, Time.parse(max).to_date]
  end

  def eml_protocols
    @eml.methods do
      non_dataset_protocols.each { |protocol| protocol.to_eml_ref(@eml) }
    end
  end

  def eml_data_format
    @eml.dataFormat do
      @eml.textFormat do
        @eml.numHeaderLines (data_access_statement.lines.to_a.size + 4).to_s
        @eml.attributeOrientation 'column'
        @eml.simpleDelimited do
          @eml.fieldDelimiter ','
        end
      end
    end
  end

  def eml_physical
    @eml.physical do
      @eml.objectName title
      @eml.encodingMethod 'None'
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
