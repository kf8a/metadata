xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Area 4 Publications"
    xml.description "Area 4 publications"
    xml.link citations_url

    [@submitted_citations, @forthcoming_citations, @citations].flatten.each do |citation|
      xml.item do
        xml.title citation.formatted
        xml.description textilize(citation.abstract)
        xml.category citation.state
        xml.pubDate citation.updated_at
        xml.link citation_url(citation)
        xml.guid citation_url(citation) 
      end
    end
  end
end
