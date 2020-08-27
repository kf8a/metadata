# frozen_string_literal: true

require 'rexml/document'

# A variate is a variable that is measured or recorded. It represents the
# column in a datatable.
class Variate < ApplicationRecord
  include REXML
  belongs_to :datatable, touch: true, optional: true
  belongs_to :unit, optional: true

  scope :valid_for_eml, -> { where("measurement_scale != '' AND description != ''") }

  def to_eml(xml = ::Builder::XmlMarkup.new)
    @eml = xml
    @eml.attribute do
      @eml.attributeName name
      @eml.attributeDefinition description
      eml_measurement_scale
    end
  end

  def human_name
    unit.try(:human_name)
  end

  private

  def eml_measurement_scale
    @eml.measurementScale do
      self.measurement_scale = 'dateTime' if measurement_scale == 'datetime'

      @eml.tag!(measurement_scale) do
        measurement_scale_as_eml(measurement_scale)
      end
    end
  end

  def measurement_scale_as_eml(measurement_scale)
    case measurement_scale
    when 'interval' then eml_interval
    when 'ratio' then eml_ratio
    when 'ordinal' then nil
    when 'nominal'then eml_nominal
    when 'dateTime' then eml_date_time
    end
  end

  def eml_unit
    @eml.unit do
      if unit.try(:in_eml)
        @eml.standardUnit unit_name
      else
        @eml.customUnit unit_name
      end
    end
  end

  def unit_name
    unit.try(:name)
  end

  def eml_date_time
    @eml.formatString date_format.presence || 'YYYY-MM-DD'
    @eml.dateTimePrecision '1'
    @eml.dateTimeDomain do
      @eml.bounds do
        @eml.minimum '1987-4-18', 'exclusive' => 'true'
      end
    end
  end

  def eml_nominal
    @eml.nonNumericDomain do
      @eml.textDomain do
        @eml.definition description
      end
    end
  end

  def eml_interval
    eml_unit
    eml_precision_and_number_type
  end

  def eml_ratio
    eml_unit
    eml_precision_and_number_type
  end

  def eml_precision_and_number_type
    @eml.precision precision.to_s if precision
    @eml.numericDomain do
      @eml.numberType data_type
    end
  end
end
