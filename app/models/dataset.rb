require 'builder'

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

  accepts_nested_attributes_for :affiliations, :allow_destroy => true

  acts_as_taggable_on :keywords

  def to_label
    "#{title} (#{dataset})"
  end

  def to_s
    "#{dataset}"
  end

  def datatable_people
    datatables.collect { |table| table.personnel.keys }.flatten
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

  def xml
    @xml ||= Builder::XmlMarkup.new
  end

  def to_eml
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version => '1.0'
    xml.tag!("eml:eml",
        'xmlns:eml'           => 'eml://ecoinformatics.org/eml-2.1.0',
        'xmlns:set'           => 'http://exslt.org/sets',
        'xmlns:exslt'         => 'http://exslt.org/common',
        'xmlns:stmml'         => 'http://www.xml-cml.org/schema/stmml',
        'xmlns:xsi'           => 'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:schemaLocation'  => 'eml://ecoinformatics.org/eml-2.1.0 eml.xsd',
        'packageId'           => package_id,
        'system'              => 'KBS LTER') do
      eml_access
      xml.dataset do
        xml.title title
        xml.creator 'id' => 'KBS LTER' do
          xml.positionName 'Data Manager'
        end
        [people, datatable_people].flatten.uniq.each do |person|
          xml.associatedParty 'id' => person.person, 'scope' => 'document' do
            eml_individual_name(person)
            address(person)
            if person.phone
              xml.phone person.phone, 'phonetype' => 'phone'
            end
            if person.fax
              xml.phone person.fax, 'phonetype' => 'fax'
            end
            xml.electronicMailAddress person.email if person.email
            xml.role person.lter_roles.first.try(:name).try(:singularize)
          end
        end
        xml.abstract do
          xml.para textilize(abstract)
        end
        keyword_sets
        contact_info
        datatables.each do |datatable|
          if datatable.valid_for_eml
            datatable.to_eml(xml)
          end
        end
      end
      if custom_units.present?
        eml_custom_unit_list
      end
    end
    # unless initiated.nil? or completed.nil?
    #   coverage = eml_dataset.add_element('coverage')
    #   temporal_coverage = coverage.add_element('temporalCoverage')
    #   range_of_dates = temporal_coverage.add_element('rangeOfDates')
    #   begin_calendar_date = range_of_dates.add_element('beginDate').add_element('calendarDate')
    #   end_calendar_date = range_of_dates.add_element('endDate').add_element('calendarDate')
    #   begin_calendar_date.add_text(initiated.to_s)
    #   end_calendar_date.add_text(completed.to_s)
    # end
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

  def restricted?
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
    xml.additionalMetadata do
      xml.metadata do
        xml.tag!('stmml:unitList', 'xsi:schemaLocation' => " http://lter.kbs.msu.edu/Data/schemas/stmml.xsd")
        logger.info custom_units
        custom_units.each do |unit|
          xml.tag!('stmml:unit',
                  'id' => unit.name,
                  'multiplierToSI' => unit.multiplier_to_si,
                  'parentSI' => unit.parent_si,
                  'unitType' => unit.unit_type,
                  'name' => unit.name)
        end
      end
    end
  end

  def eml_individual_name(person)
    xml.individualName do
      xml.givenName person.given_name
      xml.surName person.sur_name
    end
  end

  def eml_access
    xml.access 'scope' => 'document', 'order' => 'allowFirst', 'authSystem' => 'knb' do
      eml_allow('uid=KBS,o=lter,dc=ecoinformatics,dc=org', 'all')
      eml_allow('public','read')
    end
  end

  def eml_allow(principal, permission)
    xml.allow do
      xml.principal principal
      xml.permission permission
    end
  end

  def keyword_sets
    xml.keywordSet do
      ['LTER','KBS','Kellogg Biological Station', 'Hickory Corners', 'Michigan', 'Great Lakes'].each do| keyword |
        xml.keyword keyword, 'keywordType' => 'place'
      end
    end
  end

  def contact_info
    xml.contact do
      xml.organizationName 'Kellogg Biological Station'
      xml.positionName 'Data Manager'
      p = Person.new( :organization => 'Kellogg Biological Station',
        :street_address => '3700 East Gull Lake Drive',
        :city => 'Hickory Corners',:locale => 'Mi',:postal_code => '49060',
        :country => 'USA')
      address(p)
      xml.electronicMailAddress 'data.manager@kbs.msu.edu'
      xml.onlineUrl 'http://lter.kbs.msu.edu'
    end
  end

  def address(person)
    xml.address 'scope' => 'document' do
      xml.deliveryPoint person.organization if person.organization
      xml.deliveryPoint person.street_address if person.street_address
      xml.city person.city if person.city
      xml.administrativeArea person.locale if person.locale
      xml.postalCode person.postal_code if person.postal_code
      xml.country person.country if person.country
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
#  version      :integer
#  core_dataset :boolean         default(FALSE)
#  project_id   :integer
#  metacat_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#  sponsor_id   :integer
#  website_id   :integer
#
