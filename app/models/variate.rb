# frozen_string_literal: true

require 'rexml/document'

# A variate is a variable that is measured or recorded. It represents the
# column in a datatable.
class Variate < ApplicationRecord
  belongs_to :datatable, touch: true, optional: true
  belongs_to :unit, optional: true
  has_many :ordinal_values, dependent: :destroy

  scope :valid_for_eml, -> { where("measurement_scale != '' AND description != ''") }

  def to_eml(xml = ::Builder::XmlMarkup.new)
    EmlVariateBuilder.new(self).build(xml)
  end

  def human_name
    unit.try(:human_name)
  end

  private

  def unit_name
    unit.try(:name)
  end

end
