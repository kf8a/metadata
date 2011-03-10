class BookCitation < Citation
  def as_endnote
    endnote = "%0 "
    endnote += "Book Section\n"
    endnote += "%T #{title}\n"
    authors.each { |author| endnote += "%A #{author.formatted}\n" }
    editors.each { |editor| endnote += "%E #{editor.formatted}\n" }
    endnote += "%B #{publication}\n"
    endnote += "%I #{publisher}\n"
    endnote += "%C #{address}\n"
    endnote += "%V #{volume}\n" unless volume.blank?
    endnote += "%@ #{page_numbers}\n" unless page_numbers.blank?
    endnote += "%D #{pub_year}" unless pub_year.blank?
    endnote += "\n%X #{abstract}" unless abstract.blank?
    endnote
  end

  def formatted
    "#{author_and_year}. #{title}. #{page_numbers_book}#{editor_string}. #{publication}. #{publisher}, #{address}."
  end

  private

  def bibtex_type
    :book
  end
end