# frozen_string_literal: true

require 'builder'
require 'nokogiri'
require 'open-uri'
require 'date'
require 'eml'
require 'date_range_formatter'

# A dataset is the central model datasets hold tables, protocols and contact into
class Dataset < ApplicationRecord
  has_many :affiliations, -> { order 'seniority' }, dependent: :destroy
  has_many :datatables, -> { order 'name' }, dependent: :nullify
  has_many :people, through: :affiliations
  belongs_to :project, optional: true
  has_many :protocols, -> { where 'active is true' }, dependent: :nullify
  has_many :roles, -> { uniq }, through: :affiliations
  belongs_to              :sponsor
  has_and_belongs_to_many :studies
  has_and_belongs_to_many :themes
  belongs_to              :website, optional: true
  has_many                :data_versions, dependent: :destroy
  has_many                :dataset_dois, dependent: :destroy
  # has_many :data_usages, dependent: :destroy
  # has_many :citations, through: data_usages
  #
  validates :abstract, presence:   true
  validates :dataset,  uniqueness: true

  accepts_nested_attributes_for :affiliations, allow_destroy: true

  acts_as_taggable_on :keywords

  has_many_attached :files

  after_touch do
    increment_version
  end

  def to_label
    "#{title} (#{dataset})"
  end

  def to_s
    dataset
  end

  def ld_json
    { "@context": "http://schema.org",
      "@type": "Dataset",
      "name": title,
      description: short_abstract,
      "url": "https://lter.kbs.msu.edu/datasets/#{id}",
      "sameAs": "https://doi.org/#{current_doi.to_s}",
      "includedInDataCatalog": {
        "@type" => "DataCatalog",
        name: "KBS LTER Datatable Catalog",
        url: "https://lter.kbs.msu.edu/datatables"
      }
    }
  end

  def short_abstract
    abstract.truncate(100, separator: ' ')
  end

  def current_doi
    dataset_dois.order('version desc').first
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

  def collect_roles(name)
    role = Role.find_by(name: name)
    affiliations.collect { |affiliation| affiliation.person if affiliation.role == role }.compact
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
    data_end_date || completed
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

  def restricted_to_members?
    sponsor.try(:data_restricted?)
  end

  def creators
    datatables.collect(&:leads).flatten.uniq.compact
  end

  def core_areas
    datatables.map(&:core_areas).flatten.uniq
  end

  def default_bounding_coordinates
    {
      westBoundingCoordinate: -85.404699,
      eastBoundingCoordinate: -85.366857,
      northBoundingCoordinate: 42.420265,
      southBoundingCoordinate: 42.391019
    }
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

  def has_citations?
    datatables.collect do | datatable|
      !datatable.citations.empty?
    end.include?(true)
  end

  def to_eml
    builder = EmlDatasetBuilder.new(self)
    builder.to_eml
  end
end
