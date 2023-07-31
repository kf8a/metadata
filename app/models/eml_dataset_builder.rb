# frozen_string_literal: true

require 'erb'

# Build an eml dataset
class EmlDatasetBuilder
  attr_reader :dataset

  def initialize(dataset)
    @dataset = dataset
  end

  def to_eml
    @eml = ::Builder::XmlMarkup.new
    @eml.instruct! :xml, version: '1.0'

    @eml.tag!(
      'eml:eml',
      'xmlns:eml' => 'https://eml.ecoinformatics.org/eml-2.2.0',
      'xmlns:stmml' => 'http://www.xml-cml.org/schema/stmml-1.1',
      'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
      'xsi:schemaLocation' =>
        'https://eml.ecoinformatics.org/eml-2.2.0 https://lter.kbs.msu.edu/docs/eml-2.2.0/eml.xsd',
      'packageId' => dataset.package_id,
      'system' => 'KBS LTER'
    ) do
      eml_access
      eml_dataset
      eml_custom_unit_list if dataset.custom_units.present?
    end
  end

  def custom_unit_fully_specified(unit)
    @eml.tag!(
      'stmml:unit',
      id: unit.name,
      multiplierToSI: unit.multiplier_to_si,
      parentSI: unit.parent_si,
      unitType: unit.unit_type,
      name: unit.name
    )
  end

  def custom_unit_partially_specified(unit)
    @eml.tag!(
      'stmml:unit',
      id: unit.name, multiplierToSI: unit.multiplier_to_si, parentSI: unit.parent_si, name: unit.name
    )
  end

  def custom_unit_minimum(unit)
    @eml.tag!('stmml:unit', id: unit.name, name: unit.name)
  end

  def build_custom_unit(unit)
    case unit
    when unit.multiplier_to_si && unit.parent_si && unit.unit_type
      custom_unit_fully_specified(unit)
    when unit.multiplier_to_si && unit.parent_si
      custom_unit_partially_specified(unit)
    else
      custom_unit_minimum(unit)
    end
  end

  def custom_unit_list
    @eml.tag!(
      'stmml:unitList',
      'xmlns:stmml' => 'http://www.xml-cml.org/schema/stmml-1.1',
      'xmlns' => 'http://www.xml-cml.org/schema/stmml',
      'xsi:schemaLocation' =>
        'http://www.xml-cml.org/schema/stmml-1.1 http://nis.lternet.edu/schemas/EML/eml-2.1.0/stmml.xsd'
    ) { dataset.custom_units.each { |unit| build_custom_unit(unit) } }
  end

  def eml_custom_unit_list
    @eml.additionalMetadata { @eml.metadata { custom_unit_list } }
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

    @eml.methods { eml_protocols.each { |protocol| protocol.to_eml(@eml) } }
  end

  def dataset_id
    Rails.application.routes.url_helpers.dataset_url(
      dataset,
      format: 'eml', host: 'lter.kbs.msu.edu', protocol: 'https'
    )
  end

  def eml_dataset
    @eml.dataset do
      eml_resource_group
      contact_info
      @eml.publisher { @eml.organizationName 'KBS LTER' }
      eml_methods
      eml_project if dataset.project
      dataset.datatables.each do |table|
        table.to_eml(@eml) if table.on_web && table.valid_for_eml? && !table.is_restricted
      end
      eml_files
    end
  end

  def eml_files
    return unless dataset.files.attached?

    dataset.files.each do |file|
      @eml.otherEntity do
        @eml.entityName file.name
        @eml.physical do
          @eml.objectName file.name
          @eml.dataFormat { @eml.externallyDefinedFormat { @eml.formatName 'csv' } }
          @eml.distribution { @eml.online { @eml.url Rails.application.routes.url_helpers.rails_blob_path(file) } }
        end
        @eml.entityType 'File'
      end
    end
  end

  def eml_project
    @eml.project do
      @eml.title dataset.project.title
      @eml.personnel do
        @eml.organizationName dataset.project.organizationName
        @eml.role "program"
      end
      eml_award(dataset.project)
    end
  end

  def eml_award(project)
    @eml.award do |award|
      award.funderName project.funder_name
      award.funderIdentifier project.funder_identifier
      award.awardNumber project.award_number
      award.title project.title
      award.awardUrl ERB::Util.url_encode(project.award_url)
    end
  end

  def project_party; end

  def eml_resource_group
    @eml.alternateIdentifier dataset_id, system: 'lter.kbs.msu.edu'
    @eml.title "#{dataset.title} at the Kellogg Biological Station, Hickory Corners, MI " +
                 DateRangeFormatter.year_range(dataset.temporal_extent)
    eml_creator
    eml_people
    eml_pubdate
    eml_abstract
    eml_keyword_sets
    eml_intellectual_rights
    eml_coverage
  end

  def eml_intellectual_rights
    if dataset.cc0
      @eml.intellectualRights do
        @eml.para 'This information is released under the Creative Commons license - Attribution - CC BY (https://creativecommons.org/licenses/by/4.0/). The consumer of these data ("Data User" herein) is required to cite it appropriately in any publication that results from its use. The Data User should realize that these data may be actively used by others for ongoing research and that coordination may be necessary to prevent duplicate publication. The Data User is urged to contact the authors of these data if any questions about methodology or results occur. Where appropriate, the Data User is encouraged to consider collaboration or co-authorship with the authors. The Data User should realize that misinterpretation of data may occur if used out of context of the original study. While substantial efforts are made to ensure the accuracy of data and associated documentation, complete accuracy of data sets cannot be guaranteed. All data are made available "as is." The Data User should be aware, however, that data are updated periodically and it is the responsibility of the Data User to check for new versions of the data. The data authors and the repository where these data were obtained shall not be liable for damages resulting from any use or misinterpretation of the data. Thank you.'
      end
      @eml.licensed do
        @eml.licenseName "Creative Commons Attribution 4.0 International"
        @eml.url "https://creativecommons.org/licenses/by/4.0/"
        @eml.identifier "CC-BY-4.0"
      end
    else
      @eml.intellectualRights do
        @eml.para 'Data in the KBS LTER core database may not be published without written' \
          ' permission of the lead investigator or project director. These restrictions' \
          " are intended mainly to preserve the primary investigators' rights to first" \
          ' publication and to ensure that data users are aware of the limitations' \
          ' that may be associated with any specific data set. These restrictions apply' \
          ' to both the baseline data set and to the data sets associated with specific' \
          ' LTER-supported subprojects.'
        @eml.para 'All publications of KBS data and images must acknowledge KBS LTER support.'
      end
    end
  end

  def eml_creator
    dataset.creators.empty? ? eml_data_manager : eml_creators
  end

  def eml_creators
    dataset.creators.each do |person|
      @eml.creator do
        builder = EmlPersonBuilder.new(person)
        builder.eml_party(@eml)
      end
    end
  end

  def eml_data_manager
    @eml.creator { @eml.positionName 'Data Manager' }
  end

  def eml_pubdate
    @eml.pubDate Time.zone.today
  end

  def eml_people
    [dataset.people, dataset.datatable_people].flatten.uniq.compact.each do |person|
      role = dataset.datatables.collect { |x| x.which_roles(person) }.flatten.compact.first
      role ||= dataset.which_roles(person).first
      role_name = role.try(:name)
      next if ['investigator', 'lead investigator'].include?(role_name)

      person.to_eml(@eml, role_name)
    end
  end

  def eml_abstract
    return unless dataset.abstract?
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
    eml_iso_19115_keywords
  end

  def eml_iso_19115_keywords
    @eml.keywordSet do
      %w[farming biota].each { |keyword| @eml.keyword keyword, keywordType: 'theme' }
      @eml.keywordThesaurus "https://apps.usgs.gov/thesaurus/thesaurus-full.php?thcode=15"
    end
  end

  def eml_custom_keywords
    return if dataset.keyword_list.empty?

    @eml.keywordSet { dataset.keyword_list.each { |keyword_tag| @eml.keyword keyword_tag.to_s } }
  end

  def eml_place_keywords
    @eml.keywordSet { place_keyword_set.each { |keyword| @eml.keyword keyword, keywordType: 'place' } }
  end

  def eml_core_area_keywords
    return if dataset.core_areas.empty?

    @eml.keywordSet do
      dataset.core_areas.each { |keyword| @eml.keyword keyword.name }
      @eml.keywordThesaurus 'LTER Core Research Area'
    end
  end

  def eml_datatable_keywords
    datatable_keywords = dataset.datatables.collect(&:keyword_names).flatten.uniq.first
    return unless datatable_keywords
    return if datatable_keywords.empty?

    @eml.keywordSet do
      datatable_keywords.split(/ /).each { |keyword| @eml.keyword keyword, keywordType: 'theme' }
    end
  end

  def contact_info
    @eml.contact do
      @eml.organizationName 'Kellogg Biological Station'
      @eml.positionName 'Data Manager'
      @eml.electronicMailAddress 'lter.data.manager@kbs.msu.edu'
      @eml.onlineUrl 'http://lter.kbs.msu.edu'
      @eml.userId "02vkce854", directory: "https://ror.org/"
    end
  end

  def eml_kbs_address
    Person.new(
      organization: 'Kellogg Biological Station',
      street_address: '3700 East Gull Lake Drive',
      city: 'Hickory Corners',
      locale: 'Mi',
      postal_code: '49060',
      country: 'USA'
    )
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
        @eml.endDate { @eml.calendarDate dataset.data_end_date.to_s }
      end
    end
  end
end
