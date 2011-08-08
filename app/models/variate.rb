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
        if unit_eml.css('standardUnit').count == 1
          unit_name = unit_eml.css('standardUnit').first.text
          unit = Unit.find_or_create_by_name_and_in_eml(unit_name, true)
        else
          unit_name = unit_eml.css('customUnit').first.text
          unit = Unit.find_or_create_by_name_and_in_eml(unit_name, false)
        end
        variate.precision = variate_eml.css('precision').first.text.to_f
        variate.data_type = variate_eml.css('numberType').first.text
      elsif variate_eml.css('measurementScale ratio').count == 1
        variate.measurement_scale = 'ratio'
        variate.precision = variate_eml.css('precision').first.text.to_f
        variate.data_type = variate_eml.css('numberType').first.text
      elsif variate_eml.css('measurementScale ordinal').count == 1
        variate.measurement_scale = 'ordinal'
      elsif variate_eml.css('measurementScale nominal').count == 1
        variate.measurement_scale = 'nominal'
        variate.description = variate_eml.css('definition').first.text
      elsif variate_eml.css('measurementScale dateTime').count == 1
        variate.measurement_scale = 'dateTime'
        variate.date_format = variate_eml.css('formatString').first.text
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
    if unit.try(:in_eml)
      @eml.standardUnit unit_name
    else
      @eml.customUnit unit_name
    end
  end

  def unit_name
    self.unit.try(:name)
  end

  def eml_date_time
    @eml.formatString date_format
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
    @eml.unit do
      eml_unit
      eml_precision_and_number_type
    end
  end

  def eml_ratio
    @eml.unit do
      eml_precision_and_number_type
    end
  end

  def eml_precision_and_number_type
    self.precision ? eml_precision : default_eml_precision
    @eml.numericDomain do
      @eml.numberType data_type
    end
  end

  def eml_precision
    @eml.precision precision.to_s
  end

  def default_eml_precision
    @eml.precision do
      '1'
      @eml.comment!("default precision none specified")
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
