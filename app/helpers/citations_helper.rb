# frozen_string_literal: true

# Helper functions for citation view
module CitationsHelper
  def publication_url(citation)
    if citation.open_access
      download_citation_url(citation) #+ "/#{citation.pdf_file_name}"
    else
      download_citation_url(citation)
    end
  end

  def normalize_doi(doi)
    if doi =~ /dx.doi.org/
      doi
    elsif doi =~ /^doi.org/
      'http://' + doi
    elsif doi =~ /^http/
      doi
    else
      'http://dx.doi.org/' + doi
    end
  end
end
