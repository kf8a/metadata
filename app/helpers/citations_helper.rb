module CitationsHelper
  def publication_url(citation)
    if citation.open_access
      download_citation_url(citation) + "/#{citation.pdf_file_name}"
    else
      download_citation_url(citation)
    end
  end

  def normalize_doi(doi)
    if doi =~ /dx.doi.org/
      doi
    elsif doi =~ /^doi.org/
      'http://' + doi
    else
      'http://dx.doi.org/' + doi
    end
  end

  def humanize_citation_type(type)
    case type
    when 'ThesisCitation' then 'Dissertations only'
    when 'BulletinCitation' then 'Extension Bulletins only'
    when 'ReportCitation' then 'Reports'
    when 'BookCitation' then 'Books and Book chapters'
    when 'ArticleCitation' then 'Journal Articles'
    else 'Publications'
    end
  end
end
