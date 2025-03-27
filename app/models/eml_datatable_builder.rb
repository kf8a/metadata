# frozen_string_literal: true

# Builds EML representation of a Datatable
class EmlDatatableBuilder
    def initialize(datatable)
      @datatable = datatable
    end

    def build(xml = ::Builder::XmlMarkup.new)
      @eml = xml
      @eml.dataTable do
        @eml.alternateIdentifier @datatable.datatable_id, system: 'lter.kbs.msu.edu'
        @eml.entityName "Kellogg Biological Station LTER: #{@datatable.title} (#{@datatable.name})"
        build_description
        build_physical
        build_attributes
      end
    end

    private

    def build_description
      return unless @datatable.description

      full_sanitizer = Rails::HTML5::FullSanitizer.new
      text = full_sanitizer.sanitize(@datatable.description)
      @eml.entityDescription EML.text_sanitize(text) unless text.strip.empty?
    end

    def build_physical
      @eml.physical do
        @eml.objectName "#{@datatable.title.strip.squeeze.tr(' ', '+')}.csv"
        @eml.encodingMethod 'None'
        build_data_format
        build_distribution
      end
    end

    def build_data_format
      @eml.dataFormat do
        @eml.textFormat do
          @eml.numHeaderLines @datatable.number_of_header_lines.to_s
          @eml.numFooterLines 1
          @eml.recordDelimiter '\n'
          @eml.attributeOrientation 'column'
          build_simple_delimited
        end
      end
    end

    def build_simple_delimited
      @eml.simpleDelimited do
        @eml.fieldDelimiter ','
        @eml.collapseDelimiters 'no'
        @eml.quoteCharacter '"'
        @eml.literalCharacter '\\'
      end
    end

    def build_distribution
      @eml.distribution do
        @eml.online do
          if @datatable.is_sql
            @eml.url "https://#{@datatable.dataset.url}/datatables/#{@datatable.id}.csv"
          else
            @eml.url @datatable.data_url
          end
        end
      end
    end

    def build_attributes
      @eml.attributeList do
        @datatable.valid_variates.each do |variate|
          EmlVariateBuilder.new(variate).build(@eml)
          # variate.to_eml(@eml)
        end
      end
    end
  end