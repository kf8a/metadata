# frozen_string_literal: true

require 'nokogiri'

##
# A helper class to create the public EDI dataset table for annual reports and
# proposals
#
# Usage:
#
#      report = EdiReport.new(scope, identifier, revision)
#      report.table_row(n)
class EdiReport
  attr_reader :url_fragment, :doc, :spacing

  def initialize(scope, identifier, revision)
    @url_fragment = "/#{scope}/#{identifier}/#{revision}"
    doc_url = 'https://pasta.lternet.edu/package/metadata/eml'
    @doc = Nokogiri::XML(open(doc_url + url_fragment))
    @spacing = ' | '
  end

  ##
  # Creates the citation

  def citation
    authors + ' ' + publication_year + '. ' +
      title + '. Environmental Data Initiative. ' +
      doi
  end

  ##
  # Creates the markdown table header

  def self.table_header
    ' | row  | citation | production' \
      ' | population | organic' \
      ' | inorganic  | disturbance' \
      ' | ' + "\n"
  end

  ##
  # Creates the markdown table separator

  def self.table_spacer
    '|----' * 8 + '|' + "\n"
  end

  ##
  # Creates a markdown table row

  def table_row(row_number)
    spacing +
      row_number.to_s + spacing +
      citation + spacing +
      core_area_dots.join(spacing) +
      spacing
  end

  private

  def core_area_dots
    return unless dataset_id_attribute
    core_area_used(core_areas).collect { |x| x ? '*' : ' ' }
  end

  def core_area_used(areas)
    [
      areas.include?('Primary Production'),
      areas.include?('Popluation'),
      areas.include?('Organic Matter'),
      areas.include?('Inorganic Nutrients'),
      areas.include?('Disturbance')
    ]
  end

  def core_areas
    dataset.core_areas.collect(&:name)
  end

  def dataset
    id = dataset_id_attribute
    dataset_id, = id.split('/').last.split('.')
    Dataset.find(dataset_id)
  end

  def dataset_id_attribute
    doc.xpath('//dataset').attribute('id').try(:value)
  end

  def authors
    creators = doc.xpath('//dataset/creator/individualName')
    first_author = creators.shift

    return 'Data Manager' if first_author.nil?

    first = first_author_name(first_author)
    rest = creators.collect do |author|
      subsequent_author_name(author)
    end
    [first, rest].flatten.join(', ')
  end

  def first_author_name(xml)
    sur_name, given_name = extract_author_names(xml)
    "#{sur_name}, #{given_name.first}."
  end

  def subsequent_author_name(xml)
    sur_name, given_name = extract_author_names(xml)
    "#{given_name.first}. #{sur_name}"
  end

  def extract_author_names(xml)
    sur_name = xml.xpath('surName').text
    given_name = xml.xpath('givenName').text
    [sur_name, given_name]
  end

  def pubdate
    doc.xpath('//dataset/pubDate').text
  end

  def publication_year
    date = Date.parse(pubdate)
    date.year.to_s
  end

  def doi
    doi_url = 'https://pasta.lternet.edu/package/doi/eml' + url_fragment
    doi_string = open(doi_url).read
    doi_string.sub(/doi:/, 'https://doi.org/')
  end

  def title
    doc.xpath('//dataset/title').text
  end
end
