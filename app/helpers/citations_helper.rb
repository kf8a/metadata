module CitationsHelper
  def formatted_as_default(citation)
      authors = citation.authors.collect {|author| "#{author.sur_name} #{author.given_name}"}.join(', ')
      volume_and_page = case
        when citation.volume && citation.start_page_number && citation.ending_page_number
          "#{citation.volume}:#{citation.start_page_number}-#{citation.ending_page_number}"
        when citation.volume && citation.start_page_number
          "#{citation.volume}:#{citation.start_page_number}"
        when citation.volume
          "#{citation.volume}"
        else
          ""
        end
      
      "#{authors} #{citation.pub_year}. <em>#{citation.title}</em> #{citation.publication} #{volume_and_page}"
  end

  def formatted_as_book(citation)
     authors = citation.authors.collect {|author| "#{author.sur_name} #{author.given_name}"}.join(', ').upcase
     editors = citation.editors.collect {|editor| "#{editor.sur_name} #{author.given_name}"}.join(', ').upcase

     "#{authors} "
  end
end
