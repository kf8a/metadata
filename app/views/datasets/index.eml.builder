xml.instruct! :xml, :version => '1.0'
xml.hrv:harvestList, 'xmlns:hrv' => 'eml://ecoinformatics.org/harvestList' do

  @datasets.each do |dataset|
    next unless dataset.website && dataset.pasta_ready
    next if dataset.sponsor.data_restricted
    xml.document do
      xml.docid do
        xml.scope 'knb-lter-kbs'
        xml.identifier dataset.metacat_id.nil? ? dataset.id : dataset.metacat_id
        xml.revision dataset.version
      end
      xml.documentType "eml://ecoinformatics.org/eml-2.1.0"
      xml.documentURL  url_for(:controller => 'datasets', :action => 'show', :id => dataset, :format => :eml, :host => 'lter.kbs.msu.edu')
    end
  end
end
