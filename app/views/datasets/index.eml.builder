xml.instruct! :xml, :version => '1.0' 
xml.hrv:harvestlist, 'xmlns:hrv' => 'eml://ecoinformatics.org/harvestList'

@datasets.each do |dataset|
xml.document do
  xml.docid do
    xml.scope "knb-lter-kbs"
    xml.identifier dataset.metacat_id.nil? ? dataset.id : dataset.metacat_id 
    xml.revision dataset.version
  end
  xml.documentType "eml://ecoinformatics.org/eml-2.0.0"
  xml.documentURL  url_for(:controller => 'datasets', :action => 'show', :id => dataset, :format => :eml, :host => 'sebewa.kbs.msu.edu') 
end

end