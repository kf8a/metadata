# frozen_string_literal: true

# A Book citation contains mainly formatting styles
class BookCitation < Citation
  def book?
    true
  end

  def formatted(options = {})
    "#{author_and_year(options)} #{title_and_punctuation} #{page_numbers_book}"\
    "#{editor_string}#{publication_string}#{publisher}#{address_and_city}"
  end

  private

  def bibtex_type
    :book
  end

  def endnote_type
    "Book\n"
  end

  def publication_string
    "#{publication}. " if publication.present?
  end

  def address_and_city
    if address.present? && city.present?
      ", #{address} #{city}"
    elsif address.present?
      ", #{address}"
    elsif city.present?
      ", #{city}"
    end
  end
end
