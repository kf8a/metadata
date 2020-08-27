# frozen_string_literal: true

# A citation representing a book chapter
class ChapterCitation < Citation
  def formatted(options = {})
    "#{author_and_year(options)} #{title_and_punctuation} #{volume_and_page}"\
    " in #{eds}#{book_string}#{publisher}#{address_and_city}."
  end

  def volume_and_page
    if volume.blank?
      page_number_string
    elsif page_numbers.blank?
      volume.to_s
    else
      "Vol #{volume}, Pages #{page_numbers}"
    end
  end

  def page_number_string
    if page_numbers.blank?
      ''
    else
      "Pages #{page_numbers}"
    end
  end

  private

  def eds
    ed = editors.collect { |e| e.formatted(:natural) }.to_sentence
    postfix = if editors.empty?
                ''
              elsif editors.size > 1
                ', eds. '
              else
                ', ed. '
              end
    ed + postfix
  end

  def book
    publication.presence || secondary_title
  end

  def book_string
    "#{book}. " if book.present?
  end

  def address_and_city
    ", #{address} #{city}" if address.present? || city.present?
  end

  def bibtex_type
    :chapter
  end

  def endnote_type
    "CHAP\n"
  end
end
