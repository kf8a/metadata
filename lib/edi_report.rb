# frozen_string_literal: true

require 'nokogiri'

##
# A helper class to create the public EDI dataset table for annual reports and
# proposals
#
# Usage:
#
#      report = EdiReport.new(scope, identifier, revision)
#      report.load
#      report.table_row(n)
class EdiReport
  attr_reader :url_fragment, :doc, :SPACER
  SPACER = ' | '

  def initialize(scope, identifier, revision)
    @url_fragment = "/#{scope}/#{identifier}/#{revision}"
  end

  def load
    doc_url = 'https://pasta.lternet.edu/package/metadata/eml'
    begin
      response = URI.open(doc_url + url_fragment)
    rescue OpenURI::HTTPError => _e
      return nil
    end

    @doc = Nokogiri::XML(response)
    self
  end

  ##
  # Creates the citation

  def citation
    "#{ReportAuthor.authors(doc)} #{publication_year}. #{title.delete("\n")}. Environmental Data Initiative. #{doi}"
  end

  ##
  # Creates the markdown table header

  def self.table_header
    ' | row  | citation | production' \
      ' | population | organic' \
      ' | inorganic  | disturbance' \
      ' | supplemental information | top 10 paper |' + "\n"
  end

  ##
  # Creates the markdown table separator

  def self.table_spacer
    '|----' * 8 + '|' + "\n"
  end

  ##
  # Creates a markdown table row

  def table_row(row_number)
    dots = core_area_dots.each do |dot|
      dot
    end.join(SPACER)
    row_number.to_s + SPACER + citation + SPACER + dots
  end

  def first_author_name
    first_author = ReportAuthor.all_authors(doc).shift
    ReportAuthor.first_author_name(first_author)
  end

  def publication_year
    date = Date.parse(pubdate)
    date.year.to_s
  end

  def dataset
    id = dataset_id_attribute
    return nil unless id

    dataset_id, = id.split('/').last.split('.')
    Dataset.find(dataset_id)
  end

  private

  def core_area_dots
    return [] unless dataset_id_attribute

    core_area_used(core_areas).collect { |x| x ? "\uF0B7" : ' ' }
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

  def dataset_id_attribute
    doc.xpath('//dataset').attribute('id').try(:value)
  end

  def pubdate
    doc.xpath('//dataset/pubDate').text
  end

  def doi
    doi_url = "https://pasta.lternet.edu/package/doi/eml#{url_fragment}"
    doi_string = URI.open(doi_url).read
    doi_string.sub(/doi:/, 'https://doi.org/')
  end

  def title
    doc.xpath('//dataset/title').text
  end
end

##
# Helper for parsing authors
class ReportAuthor
  def self.authors(doc)
    creators = all_authors(doc)
    first_author = creators.shift

    first = first_author_name(first_author)
    rest = creators.collect do |author|
      subsequent_author_name(author)
    end
    [first, rest].flatten.join(', ')
  end

  def self.first_author_name(xml)
    return 'Data Manager' unless xml

    sur_name, given_name = extract_author_names(xml)
    "#{sur_name}, #{given_name.first}."
  end

  def self.subsequent_author_name(xml)
    sur_name, given_name = extract_author_names(xml)
    "#{given_name.first}. #{sur_name}"
  end

  def self.all_authors(doc)
    doc.xpath('//dataset/creator/individualName')
  end

  def self.extract_author_names(xml)
    sur_name = xml.xpath('surName').text
    given_name = xml.xpath('givenName').text
    [sur_name, given_name]
  end
end
