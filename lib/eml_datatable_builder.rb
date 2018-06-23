class EmlDatatableBuilder
  attr_accessor :datatable
  attr_accessor :eml

  def build(eml)
    @eml.dataTable 'id' => Rails.application.routes.url_helpers.datatable_path(datatable.id) do
      @eml.entityName "Kellogg Biological Station LTER: #{datatable.title}"
      if datatable.description.present?
        text =  datatable.description.gsub(/<\/?[^>]*>/, "")
        @eml.entityDescription EML.text_sanitize(text) unless text.strip.empty?
      end
#      eml_protocols if non_dataset_protocols.present?
      eml_physical
      eml_attributes
    end
  end

  def eml_protocols
    # @eml.methods do
    #   non_dataset_protocols.each { |protocol| protocol.to_eml_ref(@eml) }
    # end
  end

  def eml_data_format
    @eml.dataFormat do
      @eml.textFormat do
        @eml.numHeaderLines number_of_header_lines.to_s
        @eml.numFooterLines 1
        @eml.recordDelimiter '\n'
        @eml.attributeOrientation 'column'
        @eml.simpleDelimited do
          @eml.fieldDelimiter ','
          @eml.collapseDelimiters 'no'
          @eml.quoteCharacter '"'
          @eml.literalCharacter '\\'
        end
      end
    end
  end

  def eml_physical
    @eml.physical do
      @eml.objectName title
      @eml.encodingMethod "None"
      eml_data_format
      @eml.distribution do
        @eml.online do
          if is_sql
            @eml.url "http://#{website_name}.kbs.msu.edu/datatables/#{self.id}.csv"
          else
            @eml.url data_url
          end
        end
      end
    end
  end

  def eml_attributes
    @eml.attributeList do
      valid_variates.each do |variate|
        variate.to_eml(@eml)
      end
    end
  end
end
