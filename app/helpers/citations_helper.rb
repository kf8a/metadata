# frozen_string_literal: true

# Helper functions for citation view
module CitationsHelper
  def publication_url(citation)
    download_citation_url(citation)
  end

  def normalize_doi(doi)
    if doi.match?(%r{doi\.org/})
      "https://#{doi}"
    elsif doi.match?(%r{^https?://})
      doi
    else
      "https://doi.org/#{doi}"
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
