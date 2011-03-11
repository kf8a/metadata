class BookCitation < Citation

  def formatted
    "#{author_and_year}. #{title}. #{page_numbers_book}#{editor_string}. #{publication}. #{publisher}, #{address}."
  end

  private

  def bibtex_type
    :book
  end

  def endnote_type
    "Book Section\n"
  end

  def endnote_publication_data
    "%B #{publication}\n" + "%I #{publisher}\n" + "%C #{address}\n"
  end
end