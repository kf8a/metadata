# frozen_string_literal: true

require 'csv'
require 'eml'

# A datatable is one of the main objects in the system
# it represents a table of data generally a view in the database
class Datatable < ApplicationRecord
  attr_accessor :materialized_datatable_id

  acts_as_taggable_on :keywords

  has_and_belongs_to_many :citations
  has_one                 :collection, dependent: :destroy
  has_and_belongs_to_many :core_areas
  belongs_to              :dataset, touch: true
  has_many                :data_contributions, dependent: :destroy
  has_many                :ownerships, dependent: :destroy
  has_many                :owners, through: :ownerships, source: :user
  has_many                :people, through: :data_contributions
  has_many                :permission_requests, dependent: :destroy
  has_many                :permissions, dependent: :destroy
  has_many                :requesters, through: :permission_requests, source: :user
  has_and_belongs_to_many :protocols
  belongs_to              :study, touch: true
  belongs_to              :theme, touch: true
  has_many                :variates, -> { order :weight }
  has_many                :visualizations, -> { order :weight }

  validates :title,   presence: true
  validates :dataset, presence: true
  validates :name, uniqueness: true

  accepts_nested_attributes_for :data_contributions, allow_destroy: true
  accepts_nested_attributes_for :variates, allow_destroy: true

  scope :by_name, -> { order :name }

  has_one_attached :csv_file

  # validates_attachment_file_name :csv_cache, matches: [/csv\Z/ ]
  # validates_attachment_content_type :csv_cache, content_type: /csv\Z/

  include Workflow

  workflow do
    state :active do
      event :complete,      transitions_to: :completed
      event :mark_deleted,  transitions_to: :deleted
    end
    state :completed do
      event :revert,        transitions_to: :active
      event :mark_deleted,  transitions_to: :deleted
    end
    state :deleted do
      event :revert,        transitions_to: :active
    end
  end

  def revert
    self.completed_on = nil
    save
  end

  def complete
    self.completed_on = Time.zone.today
    save
  end

  def self.from_eml(datatable_eml)
    url = datatable_eml.css('physical distribution online url').text
    table_id = url.split('/')[-1].to_s.gsub('.csv', '')
    find_by(id: table_id.to_i) || new.from_eml(datatable_eml)
  end

  def from_eml(datatable_eml)
    self.name = datatable_eml.attributes['id'].try(:value)
    self.title = datatable_eml.css('entityName').text
    self.description = datatable_eml.css('entityDescription').text
    self.data_url = datatable_eml.css('physical distribution online url').text
    associated_models_from_eml(datatable_eml)
    save

    self
  end

  def associated_models_from_eml(datatable_eml)
    datatable_eml.css('methods methodStep').each do |protocol_eml|
      protocol_id = protocol_eml.css('protocol references').text.gsub('protocol_', '')
      protocols << Protocol.where(id: protocol_id)
    end

    datatable_eml.css('attributeList attribute').each do |variate_eml|
      variates << Variate.from_eml(variate_eml)
    end
  end

  def valid_for_eml?
    valid_variates.any?
  end

  def valid_variates
    variates.valid_for_eml
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

  def compile_personnel(source, personnel = {})
    source.each do |contribution|
      if personnel[contribution.person]
        personnel[contribution.person].push(contribution.role.try(:name))
      else
        personnel[contribution.person] = [contribution.role.try(:name)].to_a
      end
    end
    personnel
  end

  def which_roles(person)
    data_contributions.collect { |affiliation| affiliation.role if affiliation.person == person }
                      .compact
  end

  def leads
    lead_investigators = collect_roles('lead investigator')
    investigators = collect_roles('investigator')
    [lead_investigators, investigators].flatten
  end

  def collect_roles(name)
    role = Role.find_by(name: name)
    data_contributions.collect do |affiliation|
      affiliation.person if affiliation.role == role
    end.compact
  end

  def keyword_names
    keywords.collect(&:name)
  end

  def related_keywords
    # http://vocab.lternet.edu/webservice/keywordlist.php/all/csv
    agent = Mechanize.new
    keywords.collect do |keyword|
      terms = agent.get("http://vocab.lternet.edu/webservice/keywordlist.php/all/csv/#{keyword}")
      CSV.parse(terms)
    end.flatten.sort.uniq
  end

  # publish a dataset to S3 for caching
  def publish
    file = Tempfile.new('csv_cache')
    file << approved_csv
    file.close
    csv_file.attach(io: File.open(file),
                    filename: "#{id}-#{title.tr(' ', '-')}.csv",
                    content_type: 'text/csv')
    save!
    file.unlink
  end

  # remove a dataset from S3 caching
  def retract
    csv_file.purge
  end

  delegate :restricted_to_members?, to: :dataset

  # checks if the user has the right to perform the action
  # @param user [user] the user object to be queried
  # @return true if the action is allowed and false if not
  def permitted?(user)
    user.present? && owners.present? && owners.all? do |owner|
      user.permission_from?(owner, self)
    end
  end

  def pending_requesters
    requesters.collect { |user| user unless permitted?(user) }.compact
  end

  def requested_by?(user)
    requesters.include?(user)
  end

  def deniers_of(user)
    permissions.where(user_id: user, decision: 'denied').collect(&:owner)
  end

  delegate :sponsor, to: :dataset

  def can_be_qcd_by?(user)
    case sponsor_name
    when 'lter'
      user.try(:admin?) || member?(user)
    when 'glbrc'
      user.try(:admin?) || owned_by?(user)
    else
      false
    end
  end

  def can_be_downloaded_by?(user)
    if is_restricted?
      allowed_for_restricted_download?(user)
    elsif restricted_to_members?
      allowed_for_member_download?(user)
    else
      true
    end
  end

  def allowed_for_restricted_download?(user)
    user.try(:admin?) || permitted?(user) || owned_by?(user)
  end

  def allowed_for_member_download?(user)
    user.try(:admin?) ||
      permitted?(user) ||
      owned_by?(user) ||
      member?(user)
  end

  def owned_by?(user)
    owners.include?(user)
  end

  def member?(user)
    sponsors = user.try(:sponsors).to_a
    sponsors.include?(dataset.try(:sponsor))
  end

  def within_interval?(start_date, end_date)
    extent = temporal_extent

    extent[:begin_date] &&
      extent[:begin_date] >= start_date &&
      extent[:end_date] <= end_date
  end

  def title_and_years
    return title if begin_date.nil? || end_date.nil?

    year_end = end_date.year
    year_start = begin_date.year
    years = if year_end == year_start
              "(#{year_start})"
            else
              "(#{year_start} to #{ongoing? ? 'present' : year_end})"
            end
    "#{title} #{years}"
  end

  def ongoing?
    return false if completed?

    next_expected_update = update_frequency_days.presence || 365
    expected_update = end_date.year + next_expected_update / 265 + 2
    expected_update > Time.zone.now.year
  end

  def non_dataset_protocols
    protocols.reject { |protocol| dataset.protocols.include?(protocol) }.compact
  end

  def to_eml(xml = ::Builder::XmlMarkup.new)
    @eml = xml
    @eml.dataTable id: Rails.application.routes.url_helpers.datatable_path(self) do
      @eml.entityName "Kellogg Biological Station LTER: #{title} (#{name})"
      if description
        text = description.gsub(%r{<\/?[^>]*>}, '')
        @eml.entityDescription EML.text_sanitize(text) unless text.strip.empty?
      end
      #      eml_protocols if non_dataset_protocols.present?
      eml_physical
      eml_attributes
    end
  end

  def variate_names
    variates.collect { |variate| variate.try(:name) }
  end

  def variate_units
    units = variates.collect { |variate| variate.unit&.name }
    units[0] = "##{units[0]}"
    units
  end

  def completed
    dataset.try(:completed)
  end

  def status
    workflow_state || dataset.try(:status)
  end

  def csv_headers
    [
      "# #{title}\n",
      data_source,
      terms_of_use,
      variate_table,
      data_comments,
      "#{variate_names.join(',')}\n",
      "#{variate_units.join(',')}\n"
    ].join
  end

  def variate_table
    result = "#     VARIATE TABLE\n"
    result += variates.collect do |variate|
      unit = variate.try(:unit)
      %(# #{[variate.try(:name), unit.try(:name), variate.try(:description)].join("\t")}\n)
    end.join
    result += "#\n"
    result
  end

  def raw_csv(units: true)
    convert_to_csv(all_data, units)
  end

  def approved_csv
    convert_to_csv(approved_data)
  end

  def convert_to_csv(values, units: true)
    CSV.generate do |csv|
      vars = variate_names
      csv << vars
      csv << variate_units if units
      fields = values.fields
      vars = variates.collect { |variate| variate.name.downcase } unless fields.join(' ') =~ /[A-Z]/
      values.each do |row|
        csv << vars.collect { |variate| row[variate] }
      end
    end
  end

  def to_climdb
    "!#{raw_csv(false)}" # no units
  end

  def terms_of_use
    <<~HEREDOC
      # These Data are copyrighted and use in a publication requires written permission
      # as detailed in our Terms of use:  https://lter.kbs.msu.edu/data/terms-of-use/
      # Use of the data constitutes acceptance of the terms.
      #
    HEREDOC
  end

  def data_comments
    if comments
      "#\n#        DATA TABLE CORRECTIONS AND COMMENTS\n #{comments.gsub(/^/, '#')}\n#\n"
    else
      "\n"
    end
  end

  def data_source
    <<~HEREDOC
      #
      # Original Data Source: https://#{dataset.url}/datatables/#{id}
      # The newest version of the data https://#{dataset.url}/datatables/#{id}.csv
      # Full EML Metadata: https://#{dataset.url}/datasets/#{dataset.id}.eml
      #
    HEREDOC
  end

  def database_date_field
    values = ActiveRecord::Base.connection.execute(object)
    valid_date_names = %w[sample_date obs_date date datetime harvest_date year]
    values.fields.find { |field| valid_date_names.include?(field) }
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
    { begin_date: data_start_date, end_date: data_end_date }
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
      limit = excerpt_limit || 5
      query = "#{object}  offset #{offset} limit #{limit}"
      @data_preview = ActiveRecord::Base.connection.execute(query)
    end
    @data_preview
  end

  def approved_data_query
    query = object
    query += " offset #{offset}" if number_of_released_records
    query
  end

  def approved_data
    DataQuery.find(approved_data_query)
  end

  def all_data
    DataQuery.find(object)
  end

  def offset
    self.number_of_released_records ||= total_records
    result = total_records - number_of_released_records
    result.negative? ? 0 : result
  end

  def total_records
    unless @total_records
      query = "select count(*) as count from (#{object}) as t1"
      result = ActiveRecord::Base.connection.execute(query).first
      @total_records = result['count'].to_i
    end
    @total_records
  end

  def approve_data
    self.number_of_released_records = total_records
  end

  def perform_query
    query = object
    ActiveRecord::Base.connection.execute(query)
  end

  def related_tables
    dataset.datatables - [self]
  end

  def related_files
    dataset.files
  end

  def sponsor_name
    dataset.sponsor.try(:name) || 'lter'
  end

  def study_link_for(website)
    study.try(:study_url, website)
  end

  def study_name
    study.try(:name).to_s
  end

  def values
    perform_query if is_sql
  end

  def number_of_header_lines
    csv_headers.lines.to_a.size
  end

  # a datatable should not be superceded by itself
  def supercession_candidates
    Datatables.where('id <> ?', id).all
  end

  ## Utilites

  def release_all_current_records
    self.number_of_released_records = perform_query.count
    save # TODO: models should not save themselves
  end

  private

  def convert_year_to_date(year)
    "#{year}-1-1"
  end

  def year?(year)
    # assume its a year if there are only 4 characters
    return true if year.is_a?(Numeric)
    return false unless year
    return false if year.is_a?(Time)

    year.length == 4
  end

  def query_datatable_for_temporal_extent(query)
    values = ActiveRecord::Base.connection.execute(query)
    dates = values[0]

    min = dates['min']
    max = dates['max']
    # TODO: case date, year, time
    if year?(min)
      min = convert_year_to_date(min) if year?(min)
      max = convert_year_to_date(max) if year?(max)
      [Time.zone.parse(min).to_date, Time.zone.parse(max).to_date]
    elsif min.is_a?(String)
      [Time.zone.parse(min).to_date, Time.zone.parse(max).to_date]
    elsif min.is_a?(Time)
      [min.to_date, max.to_date]
    elsif min.is_a?(Date)
      [min, max]
    end
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
        eml_simple_field
      end
    end
  end

  def eml_simple_field
    @eml.simpleDelimited do
      @eml.fieldDelimiter ','
      @eml.collapseDelimiters 'no'
      @eml.quoteCharacter '"'
      @eml.literalCharacter '\\'
    end
  end

  def eml_physical
    @eml.physical do
      @eml.objectName title.tr(' ', '+')
      @eml.encodingMethod 'None'
      eml_data_format
      eml_distribution
    end
  end

  def eml_distribution
    @eml.distribution do
      @eml.online do
        if is_sql
          @eml.url "https://#{dataset.url}/datatables/#{id}.csv"
        else
          @eml.url data_url
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
