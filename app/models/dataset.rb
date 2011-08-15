require 'builder'
require 'nokogiri'
require 'open-uri'

class Dataset < ActiveRecord::Base
  has_many :datatables, :order => 'name'
  has_many :protocols, :conditions => 'active is true'
  has_many :people, :through => :affiliations
  has_many :affiliations, :order => 'seniority'
  has_many :roles, :through => :affiliations, :uniq => true
  has_and_belongs_to_many :themes
  belongs_to :project
  has_and_belongs_to_many :studies
  belongs_to :sponsor
  belongs_to :website

  validates_presence_of :abstract
  validates_uniqueness_of :dataset

  accepts_nested_attributes_for :affiliations, :allow_destroy => true

  acts_as_taggable_on :keywords

  def self.from_eml_file(file)
    from_eml(file.read)
  end

  def self.from_eml(eml_text)
    if eml_text.start_with?('http://')
      eml_doc = Nokogiri::XML(open(eml_text))
    else
      eml_doc = Nokogiri::XML(eml_text)
    end
    dataset_eml = eml_doc.css('dataset')
    dataset = self.new
    dataset.title = dataset_eml.css('title').text
    dataset.abstract = dataset_eml.css('abstract para').text
    dataset.initiated = dataset_eml.css('temporalCoverage rangeOfDates beginDate calendarDate').text
    dataset.completed = dataset_eml.css('temporalCoverage rangeOfDates endDate calendarDate').text

    eml_doc.css('protocol').each do |protocol_eml|
      dataset.protocols << Protocol.from_eml(protocol_eml)
    end

    dataset_eml.css('associatedParty').each do |person_eml|
      dataset.people << Person.from_eml(person_eml)
    end

    dataset_eml.css('dataTable').each do |datatable_eml|
      dataset.datatables << Datatable.from_eml(datatable_eml)
    end

    dataset_eml.css('keywordSet keyword').each do |keyword_eml|
      dataset.keyword_list << keyword_eml.text
    end

    dataset.save

    dataset

    #  eml_custom_unit_list if custom_units.present?
  end

  def to_label
    "#{title} (#{dataset})"
  end

  def to_s
    "#{dataset}"
  end

  def datatable_people
    datatables.collect { |table| table.datatable_personnel.keys }.flatten
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
    !datatables.index { |table| table.within_interval?(sdate, edate) }.blank?
  end

  #unpack and populate datatables and variates
  def from_eml(dataset)
    dataset.elements.each do |element|
      self.send(element.name, element.value)
    end
    dataset.elements['//dataTable'].each do |datatable|
      dtable = DataTable.new
      dtable.from_eml(datatable)
      datatables << dtable
    end
  end

  def package_id
    "knb-lter-kbs.#{metacat_id.nil? ? self.id : metacat_id}.#{version}"
  end

  def datatable_protocols
    datatables.collect {|datatable| datatable.protocols}
  end

  def to_eml
    @eml = Builder::XmlMarkup.new
    @eml.instruct! :xml, :version => '1.0'
    @eml.tag!("eml:eml",
        'xmlns:eml'           => 'eml://ecoinformatics.org/eml-2.1.0',
        'xmlns:set'           => 'http://exslt.org/sets',
        'xmlns:exslt'         => 'http://exslt.org/common',
        'xmlns:stmml'         => 'http://www.xml-cml.org/schema/stmml',
        'xmlns:xsi'           => 'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:schemaLocation'  => 'eml://ecoinformatics.org/eml-2.1.0 eml.xsd',
        'packageId'           => package_id,
        'system'              => 'KBS LTER') do
      eml_access
      eml_dataset
      eml_custom_unit_list if custom_units.present?
    end
  end

  #temporal extent
  def temporal_extent
    begin_date = nil
    end_date = nil
    datatables.each do |datatable |
      dates = datatable.temporal_extent
      datatable.update_temporal_extent
      next if dates[:begin_date].nil?
      next if dates[:end_date].nil?
      begin_date = dates[:begin_date] if begin_date.nil? || begin_date > dates[:begin_date]
      end_date = dates[:end_date] if end_date.nil? || end_date < dates[:end_date]
    end
    {:begin_date => begin_date, :end_date => end_date}
  end

  def update_temporal_extent
    dates = temporal_extent
    self.initiated = dates[:begin_date] if dates[:begin_date]
    self.completed = dates[:end_date] if dates[:end_date]
    save
  end

  def restricted_to_members?
    sponsor.try(:data_restricted?)
  end

  def custom_units
    self.datatables.collect do | datatable |
      datatable.variates.collect do | variate |
        next unless variate.unit
        next if variate.unit.in_eml
        variate.unit
      end
    end.flatten.compact.uniq
  end

  private

  def eml_custom_unit_list
    @eml.additionalMetadata do
      @eml.metadata do
        @eml.tag!('stmml:unitList', 'xsi:schemaLocation' => " http://lter.kbs.msu.edu/Data/schemas/stmml.xsd") do
          logger.info custom_units
          custom_units.each do |unit|
            @eml.tag!('stmml:unit',
                      'id' => unit.name,
                      'multiplierToSI' => unit.multiplier_to_si,
                      'parentSI' => unit.parent_si,
                      'unitType' => unit.unit_type,
                      'name' => unit.name)
          end
        end
      end
    end
  end

  def eml_access
    @eml.access 'scope' => 'document', 'order' => 'allowFirst', 'authSystem' => 'knb' do
      eml_allow('uid=KBS,o=lter,dc=ecoinformatics,dc=org', 'all')
      eml_allow('public','read')
    end
  end

  def eml_allow(principal, permission)
    @eml.allow do
      @eml.principal principal
      @eml.permission permission
    end
  end

  def eml_protocols
    (protocols + datatable_protocols).flatten.uniq.each do | protocol |
      protocol.to_eml(@eml)
    end
  end

  def eml_dataset_protocols
    # @eml.methods do
    #   protocols.each { |protocol| protocol.to_eml_ref(@eml) }
    # end
  end

  def eml_dataset
    @eml.dataset do
      eml_resource_group
      contact_info
      eml_dataset_protocols if protocols.present?
      datatables.each { |table| table.to_eml(@eml) if table.valid_for_eml }
    end
  end

  def eml_keywords
    if keyword_list.present?
      @eml.keywordSet do
        keyword_list.each do |keyword_tag|
          @eml.keyword keyword_tag.to_s
        end
      end
    end
  end

  def eml_resource_group
    @eml.title title
    eml_creator
    eml_people
    eml_abstract
    keyword_sets
    eml_keywords
    eml_coverage
  end

  def eml_creator
    @eml.creator do
      @eml.positionName 'Data Manager'
    end
  end

  def eml_people
    [people, datatable_people].flatten.uniq.compact.each do |person|
      person.to_eml(@eml)
    end
  end

  def eml_abstract
    @eml.abstract do
      @eml.para textilize(abstract)
    end
  end

  def keyword_sets
    @eml.keywordSet do
      ['LTER','KBS','Kellogg Biological Station', 'Hickory Corners', 'Michigan', 'Great Lakes'].each do| keyword |
        @eml.keyword keyword, 'keywordType' => 'place'
      end
    end
  end

  def contact_info
    @eml.contact do
      @eml.organizationName 'Kellogg Biological Station'
      @eml.positionName 'Data Manager'
      p = Person.new( :organization => 'Kellogg Biological Station',
        :street_address => '3700 East Gull Lake Drive',
        :city => 'Hickory Corners',:locale => 'Mi',:postal_code => '49060',
        :country => 'USA')
      p.eml_address(@eml)
      @eml.electronicMailAddress 'lter.data.manager@kbs.msu.edu'
      @eml.onlineUrl 'http://lter.kbs.msu.edu'
    end
  end

  def eml_coverage
    if initiated.present? && completed.present?
    @eml.coverage do
      eml_temporal_coverage 
    end
    end
  end

  def eml_temporal_coverage
    @eml.temporalCoverage do
      @eml.rangeOfDates do
        @eml.beginDate { @eml.calendarDate initiated.to_s }
        @eml.endDate   { @eml.calendarDate completed.to_s }
      end
    end
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
