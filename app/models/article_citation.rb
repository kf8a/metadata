class ArticleCitation < Citation

  def formatted
    "#{author_and_year}. #{title}. #{publication} #{volume_and_page}".rstrip
  end

  private

  def bibtex_type
    :article
  end

  def endnote_type
    "Journal Article\n"
  end

  def endnote_publication_data
    publication.present? ? "%J #{publication}\n" : ""
  end
end