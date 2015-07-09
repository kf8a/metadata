require 'rexml/document'
include REXML

class Variate < ActiveRecord::Base
  belongs_to :datatable, :touch => true
  belongs_to :unit

  scope :valid_for_eml, -> { where("measurement_scale != '' AND description != ''") }

  def self.from_eml(variate_eml)
    variate = Variate.new
    variate.set_attributes_from_eml(variate_eml)
    variate.set_unit_from_eml(variate_eml)
    variate.save

    variate
  end

  def set_attributes_from_eml(variate_eml)
    self.name              = variate_eml.css('attributeName').text
    self.description       = variate_eml.at_css('attributeDefinition, definition').text
    self.measurement_scale = variate_eml.at_css('measurementScale').at_css('nominal, ordinal, interval, ratio, dateTime').name
    self.precision         = variate_eml.at_css('precision').try(:text).try(:to_f)
    self.data_type         = variate_eml.at_css('numberType').try(:text)
    self.date_format       = variate_eml.at_css('formatString').try(:text)
  end

  def set_unit_from_eml(variate_eml)
    if variate_eml.at_css('standardUnit')
      unit_name = variate_eml.at_css('standardUnit').text
      self.unit = Unit.find_or_create_by_name_and_in_eml(unit_name, true)
    elsif variate_eml.at_css('customUnit')
      unit_name = variate_eml.at_css('customUnit').text
      self.unit = Unit.find_or_create_by_name_and_in_eml(unit_name, false)
    end
  end

  def to_eml(xml = ::Builder::XmlMarkup.new)
    @eml = xml
    @eml.attribute do
      @eml.attributeName name
      @eml.attributeDefinition description
      eml_measurement_scale
    end
  end

  def human_name
    self.unit.try(:human_name)
  end

  private
  def eml_measurement_scale
    @eml.measurementScale do
      self.measurement_scale = 'dateTime' if measurement_scale == 'datetime'

      @eml.tag!(measurement_scale) do
        case self.measurement_scale
        when 'interval' then eml_interval
        when 'ratio' then eml_ratio
        when 'ordinal' then
        when 'nominal'then  eml_nominal
        when 'dateTime' then eml_date_time
        end
      end
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
    self.unit.try(:name)
  end

  def eml_date_time
    @eml.formatString date_format.blank? ? 'YYYY-MM-DD' : date_format
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




# == Schema Information
#
# Table name: variates
#
#  id                      :integer         not null, primary key
#  name                    :string(255)
#  datatable_id            :integer
#  weight                  :integer
#  description             :text
#  missing_value_indicator :string(255)
#  unit_id                 :integer
#  measurement_scale       :string(255)
#  data_type               :string(255)
#  min_valid               :float
#  max_valid               :float
#  date_format             :string(255)
#  precision               :float
#  query                   :text
#  variate_theme_id        :integer
#
