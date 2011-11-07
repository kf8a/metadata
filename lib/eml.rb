module EML
  def EML.text_sanitize(text)
   doc = Nokogiri::HTML(text)
   doc.css('script').each {|node| node.remove }
   doc.css('link').each {|node| node.remove }
   doc.text.squeeze(" ").squeeze("\n")
  end
end
