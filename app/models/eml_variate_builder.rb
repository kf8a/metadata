# frozen_string_literal: true

require 'rexml/document'

# Builds EML representation of a Variate
class EmlVariateBuilder
  include REXML

  def initialize(variate)
    @variate = variate
  end

  def build(xml = ::Builder::XmlMarkup.new)
    @eml = xml
    @eml.attribute do
      @eml.attributeName @variate.name
      @eml.attributeDefinition @variate.description
      eml_measurement_scale
    end
  end

  private

  def eml_measurement_scale
    @eml.measurementScale do
      scale = @variate.measurement_scale
      scale = 'dateTime' if scale == 'datetime'

      @eml.tag!(scale) do
        measurement_scale_as_eml(scale)
      end
    end
  end

  def measurement_scale_as_eml(measurement_scale)
    case measurement_scale
    when 'interval' then eml_interval
    when 'ratio' then eml_ratio
    when 'ordinal' then eml_ordinal
    when 'nominal'then eml_nominal
    when 'dateTime' then eml_date_time
    end
  end

  def eml_unit
    @eml.unit do
      if @variate.unit.try(:in_eml)
        @eml.standardUnit unit_name
      else
        @eml.customUnit unit_name
      end
    end
  end

  def unit_name
    @variate.unit.try(:name)
  end

  def eml_date_time
    @eml.formatString @variate.date_format.presence || 'YYYY-MM-DD'
    @eml.dateTimePrecision '1'
    @eml.dateTimeDomain do
      @eml.bounds do
        @eml.minimum '1987-4-18', 'exclusive' => 'true'
      end
    end
  end

  def eml_nominal
    @eml.nonNumericDomain do
      if @variate.enumerated_values.any?
        @eml.enumeratedDomain do
          @variate.enumerated_values.each do |enumerated_value|
            @eml.codeDefinition do
              @eml.code enumerated_value.code
              @eml.definition enumerated_value.description
            end
          end
        end
      else
        @eml.textDomain do
          @eml.definition @variate.description
        end
      end
    end
  end

  def eml_ordinal
    @eml.nonNumericDomain do
      @eml.enumeratedDomain do
        @variate.enumerated_values.each do |enumerated_value|
          @eml.codeDefinition do
            @eml.code enumerated_value.code
            @eml.definition enumerated_value.description
          end
        end
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
    @eml.precision @variate.precision.to_s if @variate.precision
    @eml.numericDomain do
      @eml.numberType @variate.data_type
    end
  end
end