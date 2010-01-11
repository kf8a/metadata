require 'rexml/document'
include REXML
class Dataset < ActiveRecord::Base
  has_many :datatables, :order => 'name'
  has_many :protocols, :conditions => 'active is true'
  has_many :people, :through => :affiliations
  has_many :affiliations, :order => 'seniority'
  has_many :roles, :through => :affiliations, :uniq => true
  has_and_belongs_to_many :themes
  belongs_to :project
  has_and_belongs_to_many :studies

  accepts_nested_attributes_for :affiliations, :allow_destroy => true
  
  acts_as_taggable_on :keywords

  def self.find_by_date_interval(start_time, end_time)
    datasets = []
    Dataset.all.each do |dataset|
      next unless dataset.within_interval?(start_time, end_time)
      datasets << dataset
    end
    datasets
  end
  
  def self.find_by_keywords(keyword_list)
    self.find_tagged_with(keyword_list,:on => 'keywords')
  end
  
  def self.find_by_theme(theme_id)
    self.find(:all, :joins => :themes, :conditions => {:themes => {:id => theme_id}})
  end
  
  def self.find_by_person(person_id)
    self.find(:all, :joins => :people, :conditions => {:people => {:id => person_id}})
  end
  
  def self.find_by_theme_person_keywords_date(theme_id, person_id, keywords, date)
    datasets = self.all
    if theme_id
      theme_datasets = self.find_by_theme(theme_id)
      datasets = theme_datasets & datasets
    end
    if person_id
      person_datasets = self.find_by_person(person_id)
      datasets = person_datasets & datasets
    end
    if keywords && !keywords.empty?  
      keyword_datasets = self.find_by_keywords(keywords)
      datasets = keyword_datasets & datasets
    end
    
    datasets
  end
  
  def has_person(id)
    person = Person.find(id)
    people.exists?(person)
  end
  
  def within_interval?(start_date=Date.today, end_date=Date.today)
    any_within_interval = datatables.collect do |datatable|
      datatable.within_interval?(start_date, end_date)
    end
    #TODO query the start and end dates as well
    return any_within_interval.include?(true)
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
  
  def to_eml
    emldoc = Document.new(%q{<?xml version="1.0" encoding="UTF-8"?>
<eml:eml xmlns:eml="eml://ecoinformatics.org/eml-2.0.0" xmlns:set="http://exslt.org/sets" xmlns:exslt="http://exslt.org/common" xmlns:stmml="http://www.xml-cml.org/schema/stmml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="eml://ecoinformatics.org/eml-2.0.0 eml.xsd" packageId="knb-lter-kbs.1.8" system="KBS LTER">
</eml:eml>})
    e = Document.new to_xml
    eml_dataset = emldoc.root.add_element('dataset')
    eml_dataset.add_element('title').add_text(title)
    eml_dataset.add_element('creator', {'id' => 'KBS LTER'})
    people.each do | person |
      p = eml_dataset.add_element('associatedParty', {'id' => person.person, 'scope' => 'document'})
      p.add_element eml_individual_name(person)
      p.add_element address(person)
      p.add_element('phone', {'phonetype' => 'phone'}).add_text(person.phone) 
      p.add_element('phone',{'phonetype' => 'fax'}).add_text(person.fax) 
      p.add_element('electronicMailAddress').add_text(person.email)
#      p.add_element('role').add_text(person)
    end
    eml_dataset.add_element('abstract').add_element('para').add_text(abstract)
    eml_dataset.add_element keyword_sets
    eml_dataset.add_element contact_info
    eml_dataset.add_element eml_access

    coverage = eml_dataset.add_element('coverage')
    temporal_coverage = coverage.add_element('temporalCoverage')
    range_of_dates = temporal_coverage.add_element('rangeOfDates')
    begin_date = range_of_dates.add_element('beginDate')
    end_date = range_of_dates.add_element('endDate')
    begin_date.add_element('calendarDate').add_element(temporal_extent[:begin_date].to_date)
    begin_date.add_element('time').add_element(temporal_extent[:begin_date].strftime("%XZ"))
    end_date.add_element calendarDate(temporal_extent[:end_date].to_date)
    end_date.add_element time(temporal_extent[:end_date].strftime("%XZ"))

    datatables.each do |datatable|
      eml_dataset.add_element datatable.to_eml
    end
    eml_dataset.add_element('additionalMetadata').add_element eml_custom_unit_list
    emldoc.root.to_s
  end
  
private

  def eml_custom_unit_list
    custom_units = self.datatables.collect do | datatable |
      datatable.variates.collect do | variate |
        next unless variate.unit
        next unless !variate.unit.in_eml
        variate.unit.definition
      end
    end
    
    e = Element.new('stmml:unitList')
    e.add_attribute('xsi:schemaLocation',"http://www.xml-cml.org/schema/stmml http://lter.kbs.msu.edu/Data/schemas/stmml.xsd")
    
    custom_units.flatten.compact.sort.uniq.each do |unit|
      e.add_element(unit)
    end
    return e
  end

  def eml_individual_name(person)
    i = Element.new('individualName')
    i.add_element('givenName').add_text( person.given_name )
    i.add_element('surName').add_text( person.sur_name )
    return i
  end
  
  def eml_access
    a = Element.new('access')
    a.add_attribute('scope','document')
    a.add_attribute('order','allowFirst')
    a.add_attribute('authSystem', 'knb')
    a.add_element eml_allow('uid=KBS,o=lter,dc=ecoinformatics,dc=org', 'all')
    a.add_element eml_allow('public','read')
    return a
  end
  
  def eml_allow(principal, permission)
    a = Element.new('allow')
    a.add_element('principal').add_text(principal)
    a.add_element('permission').add_text(permission)  
    return a
  end
  
  def keyword_sets
    k = Element.new('keywordSet')
    ['LTER','KBS','Kellogg Biological Station', 'Hickory Corners', 'Michigan', 'Great Lakes'].each do| keyword |
      k.add_element('keyword', {'keywordType' => 'place'}).add_text(keyword)
    end
    return k
  end
  
  def contact_info
    i = Element.new('contact')
    i.add_element('organizationName').add_text('Kellogg Biological Station')
    i.add_element('positionName').add_text('Data Manager')
    p = Person.new( :organization => 'Kellogg Biological Station',
      :street_address => '3700 East Gull Lake Drive',
      :city => 'Hickory Corners',:locale => 'Mi',:postal_code => '49060',
      :country => 'USA')
    a = i.add_element address(p)
    a.add_element('electronicMailAddress').add_text('data.manager@kbs.msu.edu')
    a.add_element('onlineUrl').add_text('http://lter.kbs.msu.edu')
    return i
  end

  def address(person)
    a = Element.new('address')
    a.add_attribute('scope','document')
    a.add_element('deliveryPoint').add_text(person.organization)
    a.add_element('deliveryPoint').add_text(person.street_address)
    a.add_element('city').add_text(person.city)
    a.add_element('adminstrativeArea').add_text(person.locale)
    a.add_element('postalCode').add_text(person.postal_code)
    a.add_element('country').add_text(person.country)
    return a
  end
end

