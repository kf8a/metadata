require 'rexml/document'

include REXML

file = File.open('weather.eml')
eml = Document.new file
eml.elements['//dataset'].each do |dataset|
  doc = dataset.from_xml
  
  dataset.elements.each do |e|
    
  p doc.to_yaml
end
