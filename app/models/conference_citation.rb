class ConferenceCitation < Citation

  def formatted
    "#{author_and_year}. #{title}. #{publication} #{volume_and_page}".rstrip
  end

  private

  def bibtex_type
    :thesis
  end

  def endnote_type
    "Thesis\n"
  end

  def endnote_publication_data
    publication.present? ? "%J #{publication}\n" : ""
  end
end
