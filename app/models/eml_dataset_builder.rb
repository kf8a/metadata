# frozen_string_literal: true

# Build an eml dataset
class EmlDatasetBuilder
  attr_reader :dataset

  def initialize(dataset)
    @dataset = dataset
  end

  def to_eml
    @eml = ::Builder::XmlMarkup.new
    @eml.instruct! :xml, version: '1.0'

    @eml.tag!('eml:eml',
              'xmlns:eml'           => 'eml://ecoinformatics.org/eml-2.1.1',
              'xmlns:stmml'         => 'http://www.xml-cml.org/schema/stmml-1.1',
              'xmlns:xsi'           => 'http://www.w3.org/2001/XMLSchema-instance',
              'xsi:schemaLocation'  => 'eml://ecoinformatics.org/eml-2.1.1 http://lter.kbs.msu.edu/docs/eml/eml.xsd',
              'packageId'           => dataset.package_id,
              'system'              => 'KBS LTER') do
      eml_access
      eml_dataset
      eml_custom_unit_list if dataset.custom_units.present?
    end
  end

  def custom_unit_fully_specified(unit)
    @eml.tag!('stmml:unit',
              id:             unit.name,
              multiplierToSI: unit.multiplier_to_si,
              parentSI:       unit.parent_si,
              unitType:       unit.unit_type,
              name:           unit.name)
  end

  def custom_unit_partially_specified(unit)
    @eml.tag!('stmml:unit',
              id:             unit.name,
              multiplierToSI: unit.multiplier_to_si,
              parentSI:       unit.parent_si,
              name:           unit.name)
  end

  def custom_unit_minimual(unit)
    @eml.tag!('stmml:unit',
              id:   unit.name,
              name: unit.name)
  end

  def build_custom_unit(unit)
    case unit
    when unit.multiplier_to_si && unit.parent_si && unit.unit_type then
      custom_unit_fully_specified(unit)
    when unit.multiplier_to_si && unit.parent_si then
      custom_unit_partially_specified(unit)
    else
      custom_unit_minimum(unit)
    end
  end

  def header
    @eml.tag!('stmml:unitList',
              'xmlns:stmml': 'http://www.xml-cml.org/schema/stmml-1.1',
              'xmlns': 'http://www.xml-cml.org/schema/stmml',
              'xsi:schemaLocation': 'http://www.xml-cml.org/schema/stmml-1.1 http://nis.lternet.edu/schemas/EML/eml-2.1.0/stmml.xsd')
  end

  def eml_custom_unit_list
    @eml.additionalMetadata do
      @eml.metadata do
        header do
          dataset.custom_units.each do |unit|
            build_custom_unit(unit)
          end
        end
      end
    end
  end

  def eml_access
    @eml.access scope: 'document', order: 'allowFirst', authSystem: 'knb' do
      eml_allow('uid=KBS,o=lter,dc=ecoinformatics,dc=org', 'all')
      eml_allow('uid=sbohm,o=lter,dc=ecoinformatics,dc=org', 'all')
      eml_allow('public', 'read') if dataset.on_web
    end
  end

  def eml_allow(principal, permission)
    @eml.allow do
      @eml.principal principal
      @eml.permission permission
    end
  end

  def eml_protocols
    (dataset.protocols + dataset.datatable_protocols).flatten.uniq.keep_if(&:valid_for_eml?)
  end

  def eml_methods
    return if eml_protocols.empty?

    @eml.methods do
      eml_protocols.each do |protocol|
        protocol.to_eml(@eml)
      end
    end
  end

  def dataset_id
    Rails.application.routes.url_helpers.dataset_url(dataset, format: 'eml',
                                                              host: 'lter.kbs.msu.edu',
                                                              protocol: 'https')
  end

  def eml_dataset
    @eml.dataset('id': dataset_id) do
      eml_resource_group
      contact_info
      @eml.publisher do
        @eml.organizationName 'KBS LTER'
      end
      eml_methods
      dataset.datatables.each do |table|
        table.to_eml(@eml) if table.on_web &&
                              table.valid_for_eml? &&
                              !table.is_restricted
      end
    end
  end

  def eml_resource_group
    @eml.title dataset.title + ' at the Kellogg Biological Station, Hickory Corners, MI ' \
      + DateRangeFormatter.year_range(dataset.temporal_extent)
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
      if dataset.cc0
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

  def eml_creator
    if dataset.creators.empty?
      eml_data_manager
    else
      eml_creators
    end
  end

  def eml_creators
    dataset.creators.each do |person|
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
    [dataset.people, dataset.datatable_people].flatten.uniq.compact.each do |person|
      role = dataset.datatables.collect { |x| x.which_roles(person) }.flatten.compact.first
      role = which_roles(person).first unless role
      role_name = role.try(:name)
      next if ['investigator', 'lead investigator'].include?(role_name)
      person.to_eml(@eml, role_name)
    end
  end

  def eml_abstract
    return if dataset.abstract.blank?
    return if dataset.abstract.empty?

    @eml.abstract do
      @eml.section do
        @eml.title 'Dataset Abstract'
        @eml.para EML.text_sanitize(textilize(dataset.abstract))
        @eml.para "original data source http://lter.kbs.msu.edu/datasets/#{dataset.id}"
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
    return if dataset.keyword_list.empty?

    @eml.keywordSet do
      dataset.keyword_list.each do |keyword_tag|
        @eml.keyword keyword_tag.to_s
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
    return unless dataset.core_areas.empty?

    @eml.keywordSet do
      core_areas.each do |keyword|
        @eml.keyword  keyword.name
      end
      @eml.keywordThesaurus 'LTER Core Research Area'
    end
  end

  def eml_datatable_keywords
    datatable_keywords = dataset.datatables.collect(&:keyword_names).flatten.uniq
    return if datatable_keywords.empty?

    @eml.keywordSet do
      datatable_keywords.each do |keyword|
        @eml.keyword keyword
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
      eml_temporal_coverage if dataset.initiated.present? && dataset.data_end_date.present?
    end
  end

  def eml_geographic_coverage
    @eml.geographicCoverage do
      @eml.geographicDescription 'The areas around the Kellogg Biological Station in' \
                                 ' southwest Michigan'
      eml_bounding_coordinates
    end
  end

  def eml_bounding_coordinates
    @eml.boundingCoordinates do
      @eml.westBoundingCoordinate dataset.bounding_coordinates[:westBoundingCoordinate]
      @eml.eastBoundingCoordinate dataset.bounding_coordinates[:eastBoundingCoordinate]
      @eml.northBoundingCoordinate dataset.bounding_coordinates[:northBoundingCoordinate]
      @eml.southBoundingCoordinate dataset.bounding_coordinates[:southBoundingCoordinate]
    end
  end

  def eml_temporal_coverage
    @eml.temporalCoverage do
      @eml.rangeOfDates do
        @eml.beginDate { @eml.calendarDate dataset.initiated.to_s }
        @eml.endDate   { @eml.calendarDate dataset.data_end_date.to_s }
      end
    end
  end
end