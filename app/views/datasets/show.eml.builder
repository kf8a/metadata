xml.instruct! :xml, :version => '1.0'
xml.tag!("eml:eml",
    'xmlns:eml'           => 'eml://ecoinformatics.org/eml-2.1.0',
    'xmlns:set'           => 'http://exslt.org/sets',
    'xmlns:exslt'         => 'http://exslt.org/common',
    'xmlns:stmml'         => 'http://www.xml-cml.org/schema/stmml',
    'xmlns:xsi'           => 'http://www.w3.org/2001/XMLSchema-instance',
    'xsi:schemaLocation'  => 'eml://ecoinformatics.org/eml-2.1.0 eml.xsd',
    'packageId'           => @dataset.package_id,
    'system'              => 'KBS LTER') do
  xml << render(:partial => 'access')
  xml.dataset do
    xml.title @dataset.title
    xml.creator do
      xml.id 'KBS LTER'
      xml.positionName 'Data Manager'
    end
    [@dataset.people, @dataset.datatable_people].flatten.uniq.each do |person|
      xml.associatedParty do
        xml.id person.person
        xml.scope 'document'
        xml.individualName do
          xml.givenName person.given_name
          xml.surName person.sur_name
        end
        xml << render(:partial => address, :locals => {:person => person})
        if person.phone
          xml.phone person.phone, 'phonetype' => 'phone'
        end
        if person.fax
          xml.phone person.fax, 'phonetype' => 'fax'
        end
        xml.electronicMailAddress person.email if person.email
        xml.role person.lter_roles.first.try(:name).try(:singularize)
      end
    end
    xml.abstract do
      xml.para textilize(@dataset.abstract)
    end
    xml.keywordSet do
      ['LTER','KBS','Kellogg Biological Station', 'Hickory Corners', 'Michigan', 'Great Lakes'].each do| keyword |
        xml.keyword keyword, 'keywordType' => 'place'
      end
    end
    xml.contact do
      xml.organizationName 'Kellogg Biological Station'
      xml.positionName 'Data Manager'
      p = Person.new( :organization => 'Kellogg Biological Station',
        :street_address => '3700 East Gull Lake Drive',
        :city => 'Hickory Corners',:locale => 'Mi',:postal_code => '49060',
        :country => 'USA')
      xml << render(:partial => 'address', :locals => {:person => p})
      xml.electronicMailAddress 'data.manager@kbs.msu.edu'
      xml.onlineUrl 'http://lter.kbs.msu.edu'
    end
    @dataset.datatables.each do |datatable|
      xml << render(:partial => 'datatable', :locals => {:datatable => datatable})
    end
  end
  xml.additionalMetadata do
    xml.metadata do
      custom_units = @dataset.datatables.collect do | datatable |
        datatable.variates.collect do | variate |
          next unless variate.unit
          next if variate.unit.in_eml
          variate.unit
        end
      end

      xml.tag!('stmml:unitList', 'xsi:schemaLocation' => "http://www.xml-cml.org/schema/stmml http://lter.kbs.msu.edu/Data/schemas/stmml.xsd")
      logger.info custom_units
      custom_units.flatten.compact.uniq.each do |unit|
        xml.tag!('stmml:unit',
            'id' => unit.name,
            'multiplierToSI' => unit.multiplier_to_si,
            'parentSI' => unit.parent_si,
            'unitType' => unit.unit_type,
            'name' => unit.name)
      end
    end
  end
end