xml.instruct!
xml.eml(:eml,
        'xmlns:eml'          => "eml://ecoinformatics.org/eml-2.1.0",
        'xmlns:stmml'        => "http://www.xml-cml.org/schema/stmml-1.1",
        'xmlns:xsi'          =>"http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation' =>"eml://ecoinformatics.org/eml-2.1.0 http://nis.lternet.edu/schemas/EML/eml-2.1.0/eml.xsd",
        :packageId           => "knb-lter-kbs-100#{datatable.id}.#{datatable.dataset.version}",
        :system              =>"KBS LTER")  do

  xml.access(:scope => 'document', :order => 'allowFirst', :authSystem => 'knb') do
    xml.allow do
      xml.principal "uid=KBS,o=lter,dc=ecoinformatics,dc=org"
      xml.permission "all"
    end
    xml.allow do
      xml.principal "public"
      xml.permission "read"
    end
  end
  xml.dataset do
    xml.title datatable.title
    xml.creator do
      xml.individualName do
        xml.givenName
        xml.surName
      end
      xml.organizationName
      xml.address do
        xml.deliveryPoint
        xml.city
        xml.administrativeArea
        xml.postalCode
      end
    end

    xml.associatedParty
    xml.pubDate datatable.updated_at.to_date
    xml.language 'english'
    xml.abstract do
      xml.para datatable.description
      xml.para datatable.dataset.abstract
      xml.para "Original Metadata at http://lter.kbs.msu.edu/datatable/#{datatable.id}"
    end
    xml.keywordSet do
    end
    xml.intellectualRights do
      xml.para "Data in the KBS LTER core database may not be published without written permission of the lead investigator or project director. These restrictions are intended mainly to preserve the primary investigators' rights to first publication and to ensure that data users are aware of the limitations that may be associated with any specific data set. These restrictions apply to both the baseline data set and to the data sets associated with specific LTER-supported subprojects."
    end
    xml.coverage do
      xml.geographicCoverage do
        xml.geographicDescription "The areas around the Kellog Biological Station in southwest Michigan"
        xml.boundingCoordinates do
          xml.westBoundingCoordinate -85.404699
          xml.eastBoundingCoordinate -85.366857
          xml.northBoundingCoordinate 42.420265
          xml.southBoundingCoordinate 42.391019
        end
      end
      if datatable.begin_date.present? && datatable.end_date.present?
        xml.temporalCoverage do
          xml.rangeOfDates do
            xml.beginDate do
              xml.calendarDate datatable.begin_date
            end
            xml.endDate do
              xml.calendarDate datatable.end_date
            end
          end
        end
      end
      xml.taxonomicCoverage
    end
    xml.contact
    xml.publisher
    xml.methods
    xml.dataTable do
      xml.entityName
      xml.entityDescription
      xml.physical
      xml.coverage
      xml.attributeList
      xml.constraint
      xml.numberOfRecords
    end
  end
end
