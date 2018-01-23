require 'builder'
require 'nokogiri'
require 'open-uri'
require 'date'
require 'eml'

# A dataset is the central model datasets hold tables, protocols and contact into
class Dataset < ActiveRecord::Base
  has_many                :affiliations, -> { order 'seniority' }
  has_many                :datatables, -> { order 'name' }, dependent: :nullify
  has_many                :people, through: :affiliations
  belongs_to              :project
  has_many                :protocols, -> { where 'active is true' }
  has_many                :roles, -> { uniq }, through: :affiliations
  belongs_to              :sponsor
  has_and_belongs_to_many :studies
  has_and_belongs_to_many :themes
  belongs_to              :website
  has_many                :dataset_files
  has_many                :data_versions
  has_many                :dois

  validates :abstract, presence:   true
  validates :dataset,  uniqueness: true

  accepts_nested_attributes_for :affiliations, allow_destroy: true
  accepts_nested_attributes_for :dataset_files, allow_destroy: true

  acts_as_taggable_on :keywords

  after_touch do
    increment_version
  end

  def self.from_eml_file(file)
    from_eml(file.read)
  end

  def self.from_eml(eml_text)
    eml_doc = nil
    if eml_text.start_with?('http://')
      eml_doc = Nokogiri::XML(open(eml_text))
    else
      eml_doc = Nokogiri::XML(eml_text)
    end
    # get_validation_errors(eml_doc).presence ||
    new.from_eml(eml_doc)
  end

  def self.get_validation_errors(eml_doc)
    xsd = nil
    Dir.chdir("#{Rails.root}/test/data/eml-2.1.0") do
      xsd = Nokogiri::XML::Schema(File.read('eml.xsd'))
    end
    xsd.validate(eml_doc)
  end

  def from_eml(eml_doc)
    dataset_eml = eml_doc.css('dataset').first
    basic_attributes_from_eml(dataset_eml)
    associated_models_from_eml(dataset_eml)
    self
  end

  def to_label
    "#{title} (#{dataset})"
  end

  def to_s
    dataset
  end

  def increment_version
    self.version = version + 1
    save
  end

  def datatable_people
    datatables.collect { |table| table.datatable_personnel.keys }.flatten
  end

  def which_roles(person)
    affiliations.collect { |affiliation| affiliation.role if affiliation.person == person }.compact
  end

  def leads
    lead_investigator = Role.find_by_name('lead investigator')
    affiliations.collect { |affiliation| affiliation.person if affiliation.role == lead_investigator }.compact
  end

  def valid_request?(subdomain)
    website_name.blank? || (website_name == subdomain)
  end

  def website_name
    website.try(:name)
  end

  def within_interval?(start_date, end_date)
    sdate = start_date.to_date
    edate = end_date.to_date
    datatables.index { |table| table.within_interval?(sdate, edate) }.present?
  end

  # unpack and populate datatables and variates
  # def from_eml(dataset)
  #  dataset.elements.each do |element|
  #    self.send(element.name, element.value)
  #  end
  #  dataset.elements['//dataTable'].each do |datatable|
  #    dtable = DataTable.new
  #    dtable.from_eml(datatable)
  #    datatables << dtable
  #  end
  # end

  delegate :url, to: :website

  def package_id
    "knb-lter-kbs.#{metacat_id || id}.#{version}"
  end

  def datatable_protocols
    datatables.where(on_web: true).collect(&:protocols)
  end

  def to_eml
    @eml = ::Builder::XmlMarkup.new
    @eml.instruct! :xml, version: '1.0'
    @eml.tag!('eml:eml',
        'xmlns:eml'           => 'eml://ecoinformatics.org/eml-2.1.1',
        'xmlns:stmml'         => 'http://www.xml-cml.org/schema/stmml-1.1',
        'xmlns:xsi'           => 'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:schemaLocation'  => 'eml://ecoinformatics.org/eml-2.1.1 http://lter.kbs.msu.edu/docs/eml/eml.xsd',
        'packageId'           => package_id,
        'system'              => 'KBS LTER') do
      eml_access
      eml_dataset
      eml_custom_unit_list if custom_units.present?
    end
  end

  def temporal_extent
    begin_date, end_date = nil
    datatables.where(on_web: true).find_each do |datatable|
      dates = { begin_date: datatable.begin_date, end_date: datatable.end_date }
      next unless dates[:begin_date] && dates[:end_date]
      begin_date = [begin_date, dates[:begin_date]].compact.min
      end_date   = [end_date, dates[:end_date]].compact.max
    end
    { begin_date: begin_date, end_date: end_date }
  end

  def update_temporal_extent
    dates = temporal_extent
    self.initiated = dates[:begin_date] if dates[:begin_date]
    self.data_end_date = dates[:end_date] if dates[:end_date]
    save
  end

  def begin_date
    initiated || '1988-1-1'
  end

  def end_date
    data_end_date || Time.zone.today
  end

  # Return the bounding coordinates of all of the datatables in the dataset
  # @return a hash with  {eastBoundingCoordinate:, westBoundingCoordinate: ,
  #                       northBoundingCoordinate:, southBoundingCoordinate:}
  def bounding_coordinates
    if west_bounding_coordinate
      {
        westBoundingCoordinate: west_bounding_coordinate,
        eastBoundingCoordinate: east_bounding_coordinate,
        northBoundingCoordinate: north_bounding_coordinate,
        southBoundingCoordinate: south_bounding_coordinate

      }
    else
      default_bounding_coordinates
    end
  end
  def default_bounding_coordinates
    {
      westBoundingCoordinate: -85.404699,
      eastBoundingCoordinate: -85.366857,
      northBoundingCoordinate: 42.420265,
      southBoundingCoordinate: 42.391019
    }
  end

  def restricted_to_members?
    sponsor.try(:data_restricted?)
  end

  def custom_units
    datatables.collect do |datatable|
      datatable.variates.collect do |variate|
        next unless variate.unit
        next if variate.unit.in_eml
        variate.unit
      end
    end.flatten.compact.uniq
  end

  def creators
    datatable_leads = datatables.collect(&:leads).compact
    [leads, datatable_leads].flatten.uniq.compact
  end

  def core_areas
    datatables.map(&:core_areas).flatten.uniq
  end

  # private

  def eml_custom_unit_list
    @eml.additionalMetadata do
      @eml.metadata do
        @eml.tag!('stmml:unitList',
                  'xmlns:stmml'        => 'http://www.xml-cml.org/schema/stmml-1.1',
                  'xmlns'              => 'http://www.xml-cml.org/schema/stmml',
                  'xsi:schemaLocation' => 'http://www.xml-cml.org/schema/stmml-1.1 http://nis.lternet.edu/schemas/EML/eml-2.1.0/stmml.xsd') do
          logger.info custom_units
          custom_units.each do |unit|
            case unit
            when unit.multiplier_to_si && unit.parent_si && unit.unit_type then
              @eml.tag!('stmml:unit',
                        id:             unit.name,
                        multiplierToSI: unit.multiplier_to_si,
                        parentSI:       unit.parent_si,
                        unitType:       unit.unit_type,
                        name:           unit.name)
            when unit.multiplier_to_si && unit.parent_si then
              @eml.tag!('stmml:unit',
                        id:             unit.name,
                        multiplierToSI: unit.multiplier_to_si,
                        parentSI:       unit.parent_si,
                        name:           unit.name)
            else
              @eml.tag!('stmml:unit',
                        id:   unit.name,
                        name: unit.name)
            end
          end
        end
      end
    end
  end

  def eml_access
    @eml.access scope: 'document', order: 'allowFirst', authSystem: 'knb' do
      eml_allow('uid=KBS,o=lter,dc=ecoinformatics,dc=org', 'all')
      eml_allow('uid=sbohm,o=lter,dc=ecoinformatics,dc=org', 'all')
      eml_allow('public', 'read') if on_web
    end
  end

  def eml_allow(principal, permission)
    @eml.allow do
      @eml.principal principal
      @eml.permission permission
    end
  end

  def eml_protocols
    (protocols + datatable_protocols).flatten.uniq.keep_if(&:valid_for_eml?)
  end

  def eml_methods
    if eml_protocols.size > 0
      @eml.methods do
        eml_protocols.each do |protocol|
          protocol.to_eml(@eml)
        end
      end
    end
  end

  def eml_dataset
    @eml.dataset 'id' => Rails.application.routes.url_helpers.dataset_path(self, format: 'eml') do
      eml_resource_group
      contact_info
      @eml.publisher do
        @eml.organizationName 'KBS LTER'
      end
      eml_methods
      datatables.each do |table|
        table.to_eml(@eml) if table.on_web &&
                              table.valid_for_eml? &&
                              !table.is_restricted
      end
    end
  end

  def eml_resource_group
    @eml.title title + ' at the Kellogg Biological Station, Hickory Corners, MI ' + date_range
    eml_creator
    eml_people
    eml_pubdate
    eml_abstract
    eml_keyword_sets
    eml_intellectual_rights
    eml_coverage
  end

  def eml_intellectual_rights
    @eml.intellectualRights do
      if cc0 then
        @eml.para 'These data are licensed under the Creative Commons CC0 license.'
      else
        @eml.para 'Data in the KBS LTER core database may not be published without written'\
          ' permission of the lead investigator or project director. These restrictions'\
          " are intended mainly to preserve the primary investigators' rights to first"\
          ' publication and to ensure that data users are aware of the limitations'\
          ' that may be associated with any specific data set. These restrictions apply'\
          ' to both the baseline data set and to the data sets associated with specific'\
          ' LTER-supported subprojects.'
        @eml.para 'All publications of KBS data and images must acknowledge KBS LTER support.'
      end
    end
  end

  def date_range
    daterange = temporal_extent
    starting = daterange[:begin_date]
    ending   = daterange[:end_date]
    if starting && ending
      " (#{starting.year} to #{ending.year})"
    elsif starting
      " (#{starting.year})"
    else
      ''
    end
  end

  def eml_creator
    if creators.empty?
      eml_data_manager
    else
      eml_creators
    end
  end

  def eml_creators
    creators.each do |person|
      @eml.creator do
        person.eml_party(@eml)
      end
    end
  end

  def eml_data_manager
    @eml.creator do
      @eml.positionName 'Data Manager'
    end
  end

  def eml_pubdate
    @eml.pubDate Time.zone.today
  end

  def eml_people
    [people, datatable_people].flatten.uniq.compact.each do |person|
      role = datatables.collect { |x| x.which_roles(person) }.flatten.compact.first
      role = which_roles(person).first unless role
      role_name = role.name if role
      person.to_eml(@eml, role_name)
    end
  end

  def eml_abstract
    return unless abstract
    if abstract.present?
      @eml.abstract do
        @eml.section do
          @eml.title 'Dataset Abstract'
          @eml.para EML.text_sanitize(textilize(abstract))
          @eml.para "original data source http://lter.kbs.msu.edu/datasets/#{id}"
        end
      end
    end
  end

  def place_keyword_set
    ['LTER', 'KBS', 'Kellogg Biological Station', 'Hickory Corners', 'Michigan', 'Great Lakes']
  end

  def eml_keyword_sets
    eml_place_keywords
    eml_datatable_keywords
    eml_core_area_keywords
    eml_custom_keywords
  end

  def eml_custom_keywords
    if keyword_list.present?
      @eml.keywordSet do
        keyword_list.each do |keyword_tag|
          @eml.keyword keyword_tag.to_s
        end
      end
    end
  end

  def eml_place_keywords
    @eml.keywordSet do
      place_keyword_set.each do |keyword|
        @eml.keyword keyword, keywordType: 'place'
      end
    end
  end

  def eml_core_area_keywords
    if core_areas.present?
      @eml.keywordSet do
        core_areas.each do |keyword|
          @eml.keyword  keyword.name
        end
        @eml.keywordThesaurus 'LTER Core Research Area'
      end
    end
  end

  def eml_datatable_keywords
    datatable_keywords = datatables.collect(&:keyword_names).flatten.uniq
    unless datatable_keywords.empty?
      @eml.keywordSet do
        datatable_keywords.each do |keyword|
          @eml.keyword keyword
        end
      end
    end
  end

  def contact_info
    @eml.contact do
      @eml.organizationName 'Kellogg Biological Station'
      @eml.positionName 'Data Manager'
      p = eml_kbs_address
      p.eml_address(@eml)
      @eml.electronicMailAddress 'lter.data.manager@kbs.msu.edu'
      @eml.onlineUrl 'http://lter.kbs.msu.edu'
    end
  end

  def eml_kbs_address
    Person.new(organization:   'Kellogg Biological Station',
               street_address: '3700 East Gull Lake Drive',
               city:           'Hickory Corners',
               locale:         'Mi',
               postal_code:    '49060',
               country:        'USA')
  end

  def eml_coverage
    @eml.coverage do
      eml_geographic_coverage
      if initiated.present? && data_end_date.present?
        eml_temporal_coverage
      end
    end
  end

  def eml_geographic_coverage
    @eml.geographicCoverage do
      @eml.geographicDescription 'The areas around the Kellogg Biological Station in'\
                                 ' southwest Michigan'
      @eml.boundingCoordinates do
        @eml.westBoundingCoordinate bounding_coordinates[:westBoundingCoordinate]
        @eml.eastBoundingCoordinate bounding_coordinates[:eastBoundingCoordinate]
        @eml.northBoundingCoordinate bounding_coordinates[:northBoundingCoordinate]
        @eml.southBoundingCoordinate bounding_coordinates[:southBoundingCoordinate]
      end
    end
  end

  def eml_temporal_coverage
    @eml.temporalCoverage do
      @eml.rangeOfDates do
        @eml.beginDate { @eml.calendarDate initiated.to_s }
        @eml.endDate   { @eml.calendarDate data_end_date.to_s }
      end
    end
  end

  def self.validation_errors(eml_doc)
    xsd = nil
    Dir.chdir("#{Rails.root}/test/data/eml-2.1.0") do
      xsd = Nokogiri::XML::Schema(File.read('eml.xsd'))
    end

    xsd.validate(eml_doc)
  end

  def basic_attributes_from_eml(dataset_eml)
    self.title = dataset_eml.at_css('title').text
    self.abstract = dataset_eml.css('abstract para').text
    self.initiated = dataset_eml.css('temporalCoverage rangeOfDates beginDate calendarDate').text
    self.completed = dataset_eml.css('temporalCoverage rangeOfDates endDate calendarDate').text
    save
  end

  def associated_models_from_eml(dataset_eml)
    dataset_eml.parent.css('methods methodStep protocol').each do |protocol_eml|
      self.protocols << Protocol.from_eml(protocol_eml)
    end

    dataset_eml.css('associatedParty').each do |person_eml|
      self.people << Person.from_eml(person_eml)
    end

    dataset_eml.css('dataTable').each do |datatable_eml|
      self.datatables.new.from_eml(datatable_eml)
    end

    dataset_eml.css('keywordSet keyword').each do |keyword_eml|
      self.keyword_list << keyword_eml.text
    end

    save
  end
end

# == Schema Information
#
# Table name: datasets
#
#  id           :integer         not null, primary key
#  dataset      :string(255)
#  title        :string(255)
#  abstract     :text
#  old_keywords :string(255)
#  status       :string(255)
#  initiated    :date
#  completed    :date
#  released     :date
#  on_web       :boolean         default(TRUE)
#  version      :integer         default(1)
#  core_dataset :boolean         default(FALSE)
#  project_id   :integer
#  metacat_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#  sponsor_id   :integer
#  website_id   :integer
#
