# frozen_string_literal: true

require 'eml'
# A protocol describes how the data was collected
class Protocol < ApplicationRecord
  acts_as_taggable_on :themes
  belongs_to :dataset, optional: true
  has_and_belongs_to_many :websites
  has_and_belongs_to_many :datatables
  has_many :scribbles, dependent: :destroy
  has_many :people, through: :scribbles

  has_one_attached :pdf

  def to_s
    title
  end

  def valid_for_eml?
    title.present?
  end

  def to_eml(xml = ::Builder::XmlMarkup.new)
    @eml = xml
    @eml.methodStep do
      @eml.description EML.text_sanitize(abstract)
      @eml.protocol 'id' => "protocol_#{id}" do
        @eml.title  title
        eml_creator
        @eml.distribution do
          @eml.online do
            website_name = dataset.try(:website).try(:name) || websites.first.try(:name)
            @eml.url "http://#{website_name}.kbs.msu.edu/protocols/#{id}"
          end
        end
      end
    end
  end

  def to_eml_ref(xml = ::Builder::XmlMarkup.new)
    # xml.methodStep do
    #   xml.protocol do
    #     xml.references "protocol_#{self.id}"
    #   end
    # end
  end

  def deprecate!(other)
    other.active = false
    other.save
    self.deprecates = other.id
    self.version_tag = other.version_tag.to_i + 1
    save
  end

  def replaced_by
    Protocol.find_by(deprecates: id)
  end

  def dataset_description
    dataset.try(:dataset)
  end

  private

  def eml_creator
    @eml.creator do
      @eml.positionName 'Data Manager'
    end
  end
end
