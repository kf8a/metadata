require 'rexml/document'
include REXML

class Variate < ActiveRecord::Base
  belongs_to :datatable
  belongs_to :unit
  
  def to_eml
    eml = Element.new('attribute')
    eml.add_element('attributeName').add_text(self.name)
    eml.add_element('attributeDefinition').add_text(self.description)
    eml.add_element eml_measurement_scale unless self.measurement_scale.nil?
    return eml
  end

private
  def eml_measurement_scale
    m = Element.new('measurementScale')
    scale = m.add_element(measurement_scale)
    case self.measurement_scale
    when 'interval' then eml_interval(scale)
    when 'ratio' then eml_ratio(scale)
    when 'ordinal' then 
    when 'nominal'then  eml_nominal(scale)
    when 'dateTime' then eml_date_time(scale)
    end
    m
  end
  
  def eml_unit
    u = Element.new('unit')
    if self.unit.in_eml
      u.add_element('standardUnit').add_text(self.unit.name)
    else
      u.add_element('customUnit').add_text(self.unit.name)
      # TODO: need to add custom unit tags to the end of the document
    end
    u
  end
  
  def eml_date_time(e)
    e.add_element('formatString').add_text(self.date_format)
    e.add_element('dateTimePrecision').add_text('86400')
    e.add_element('dateTimeDomain').add_element('bounds') \
      .add_element('minimum', {'exclusive' => 'true'}).add_text('1987-4-18')
    
  end
  
  def eml_nominal(e)
    e.add_element('nonNumericDomain').add_element('textDomain').add_element('definition').add_text(self.description)
  end
  
  def eml_interval(e)
    e.add_element eml_unit
    if !self.precision
      p = e.add_element('precision').add_text('1')
      p << Comment.new("default precision none specified")
    else
      e.add_element('precision').add_text(self.precision.to_s)
    end
    e.add_element('numericDomain').add_element('numberType').add_text(self.data_type)
  end
  
  def eml_ratio(e)
    e.add_element('unit')
    if !self.precision
      p = e.add_element('precision').add_text('1')
      p << Comment.new("default precision none specified")
    else
      e.add_element('precision').add_text(self.precision.to_s)
    end
    e.add_element('numericDomain').add_element('numberType').add_text(self.data_type)
  end
end
