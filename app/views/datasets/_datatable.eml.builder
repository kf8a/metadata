xml.dataTable 'id' => datatable.name do
  xml.entityName datatable.title
  xml.entityDescription datatable.description.gsub(/<\/?[^>]*>/, "")
  xml.physical do
    xml.objectName datatable.title
    xml.encodingMethod 'None'
    xml.dataFormat do
      xml.textFormat do
        xml.numHeaderLines (datatable.data_access_statement.lines.to_a.size + 4).to_s
        xml.attributeOrientation 'column'
        xml.simpleDelimited do
          xml.fieldDelimiter ','
        end
      end
    end
    xml.distribution do
      xml.online do
        xml.url datatable.data_url
      end
    end
  end
  if datatable.variates.present?
    xml.attributeList do
      datatable.variates.each do |variate|
        xml << render(:partial => 'variate', :locals => {:variate => variate})
      end
    end
  else
    xml.attributeList nil
  end
end