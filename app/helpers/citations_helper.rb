# frozen_string_literal: true

# Helper functions for citation view
module CitationsHelper
  def publication_url(citation)
    download_citation_url(citation)
  end

  # Names a citation's abstract, pdf or data link for screen readers: the link text alone
  # ("abstract", "pdf") is the same for every citation on the page
  def citation_link_label(citation, link)
    "#{link}: #{strip_tags(citation.title.to_s).squish}, #{citation.author_and_year.to_s.squish.delete_suffix('.')}"
  end

  def normalize_doi(doi)
    if doi.match?(%r{\Ahttps?://})
      doi
    elsif doi.match?(%r{doi\.org/})
      "https://#{doi}"
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
