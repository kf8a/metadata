require 'rexml/document'
include REXML

class Variate < ActiveRecord::Base
  belongs_to :datatable
  belongs_to :unit

  def self.from_eml(variate_eml)
    variate_name = variate_eml.css('attributeName').text
    variate = Variate.find_by_name(variate_name)
    unless variate.present?
      variate = Variate.new
      variate.name = variate_name
      variate.description = variate_eml.css('attributeDefinition').text
      if variate_eml.css('measurementScale interval').count == 1
        variate.measurement_scale = 'interval'
        unit_eml = variate_eml.css('measurementScale interval unit').first
        variate.precision = variate_eml.css('precision').first.text.to_f
        variate.data_type = variate_eml.css('numberType').first.text
      elsif variate_eml.css('measurementScale ratio').count == 1
        variate.measurement_scale = 'ratio'
        variate.precision = variate_eml.css('precision').first.try(:text).try(:to_f)
        variate.data_type = variate_eml.css('numberType').first.text
      elsif variate_eml.css('measurementScale ordinal').count == 1
        variate.measurement_scale = 'ordinal'
      elsif variate_eml.css('measurementScale nominal').count == 1
        variate.measurement_scale = 'nominal'
        variate.description = variate_eml.css('definition').first.text if variate.description.blank?
      elsif variate_eml.css('measurementScale dateTime').count == 1 || variate_eml.css('measurementScale datetime').count == 1
        variate.measurement_scale = 'dateTime'
        variate.date_format = variate_eml.css('formatString').first.text
      end

      if variate_eml.css('standardUnit').count == 1
        unit_name = variate_eml.css('standardUnit').first.text
        variate.unit = Unit.find_or_create_by_name_and_in_eml(unit_name, true)
      elsif variate_eml.css('customUnit').count == 1
        unit_name = variate_eml.css('customUnit').first.text
        variate.unit = Unit.find_or_create_by_name_and_in_eml(unit_name, false)
      end

      variate.save
    end

    variate
  end

  def valid_for_eml
    measurement_scale.present? && description.present?
  end

  def to_eml(xml = Builder::XmlMarkup.new)
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
    @eml.dateTimePrecision '86400'
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
