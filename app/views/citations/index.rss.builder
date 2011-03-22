xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Area 4 Publications"
    xml.description "Area 4 publications"
    xml.link citations_url

    @citations.each do |citation|
      xml.item do
        xml.title citation.formatted
        xml.description citation.abstract
        xml.pubDate citation.updated_at
        xml.link citation_url(citation)
        xml.guid citation_url(citation) 
      end
    end
  end
end
