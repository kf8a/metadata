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

end