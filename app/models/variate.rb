require 'rexml/document'
include REXML

class Variate < ActiveRecord::Base
  belongs_to :datatable
  belongs_to :unit

  def to_eml
    eml = Element.new('attribute')
    eml.add_element('attributeName').add_text(self.name)
    eml.add_element('attributeDefinition').add_text(self.description)
    eml.add_element eml_measurement_scale if self.measurement_scale

    eml
  end

  def human_name
    self.unit.try(:human_name)
  end

private
  def eml_measurement_scale
    measurement_scale_element = Element.new('measurementScale')
    scale = measurement_scale_element.add_element(measurement_scale)
    case self.measurement_scale
    when 'interval' then eml_interval(scale)
    when 'ratio' then eml_ratio(scale)
    when 'ordinal' then
    when 'nominal'then  eml_nominal(scale)
    when 'dateTime' then eml_date_time(scale)
    end
    measurement_scale_element
  end

  def eml_unit
    unit_element = Element.new('unit')
    unit_type = self.unit.try(:in_eml) ? 'standardUnit' : 'customUnit'
    unit_element.add_element(unit_type).add_text(unit_name)

    unit_element
  end

  def unit_name
    self.unit.try(:name)
  end

  def eml_date_time(element)
    element.add_element('formatString').add_text(self.date_format)
    element.add_element('dateTimePrecision').add_text('86400')
    element.add_element('dateTimeDomain').add_element('bounds') \
      .add_element('minimum', {'exclusive' => 'true'}).add_text('1987-4-18')

  end

  def eml_nominal(element)
    element.add_element('nonNumericDomain').add_element('textDomain').add_element('definition').add_text(self.description)
  end

  def eml_interval(element)
    element.add_element eml_unit
    eml_precision_and_number_type(element)
  end

  def eml_ratio(element)
    element.add_element('unit')
    eml_precision_and_number_type(element)
  end

  def eml_precision_and_number_type(element)
    precision_element = self.precision ? eml_precision : default_eml_precision
    element.add_element precision_element
    element.add_element('numericDomain').add_element('numberType').add_text(self.data_type)
  end

  def eml_precision
    Element.new('precision').add_text(self.precision.to_s)
  end

  def default_eml_precision
    precision_element = Element.new('precision').add_text('1')
    precision_element << Comment.new("default precision none specified")
    precision_element
  end
end
