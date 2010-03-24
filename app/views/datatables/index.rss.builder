xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Datatables"
    xml.description "glbrc datatables"
    xml.link datatables_url(:format => :rss)
    
    for datatable in @datatables
      xml.item do
        xml.title datatable.title
        xml.description datatable.description
        xml.pubDate Time.now().to_s(:rfc822)
        xml.link datatable_url(datatable, :format =>  :rss)
        xml.guid datatable_url(datatable, :format => :rss)
      end
    end
  end
end
