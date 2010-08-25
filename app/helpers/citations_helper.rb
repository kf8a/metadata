module CitationsHelper
  def formatted_as_default(citation)
      authors = citation.authors.collect {|author| "#{author.sur_name} #{author.given_name}"}.join(', ')
      "#{authors}. #{citation.pub_year}. <em>#{citation.title}</em> #{citation.publication} #{citation.volume}:#{citation.start_page_number}-#{citation.ending_page_number}"
  end
end
