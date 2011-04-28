xml.attribute do
  xml.attributeName variate.name
  xml.attributeDefinition variate.description
  if variate.measurement_scale
    xml.measurementScale do
      xml.tag!(variate.measurement_scale) do
        case variate.measurement_scale
        when 'interval'
          xml.unit do
            unit_type = variate.unit.try(:in_eml) ? 'standardUnit' : 'customUnit'
            xml.tag!(unit_type) do
              variate.unit_name
            end
            if variate.precision
              xml.precision variate.precision.to_s
            else
              xml.precision '1' do
                xml.comment!("default precision none specified")
              end
            end
            xml.numericDomain do
              xml.numberType variate.data_type
            end
          end
        when 'ratio'
          xml.unit do
            if variate.precision
              xml.precision variate.precision.to_s
            else
              xml.precision '1' do
                xml.comment!("default precision none specified")
              end
            end
            xml.numericDomain do
              xml.numberType variate.data_type
            end
          end
        when 'ordinal'
        when 'nominal'
          xml.nonNumericDomain do
            xml.textDomain do
              xml.definition variate.description
            end
          end
        when 'dateTime'
          xml.formatString variate.date_format
          xml.dateTimePrecision '86400'
          xml.dateTimeDomain do
            xml.bounds do
              xml.minimum '1987-4-18', 'exclusive' => 'true'
            end
          end
        end
      end
    end
  end
end