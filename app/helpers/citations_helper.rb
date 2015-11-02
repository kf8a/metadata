module CitationsHelper
  def publication_url(citation) 
    if citation.open_access
      download_citation_url(citation) + "/#{citation.pdf_file_name}"
    else
      download_citation_url(citation)
    end
  end
end
