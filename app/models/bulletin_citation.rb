# Formatting for bulletins
class BulletinCitation < Citation
  def formatted(options = {})
    "#{author_and_year(options)} #{title_and_punctuation} #{editor_string}"\
    "#{publication_string}#{volume_and_page}#{publisher_string}#{address_and_city}."
  end

  private

  def bibtex_type
    :report
  end

  def endnote_type
    "Pamphlet\n"
  end

  def publisher_string
    publisher + ', ' if publisher.present?
  end

  def publication_string
    publication + ', ' if publication.present?
  end

  def address_and_city
    city if city.present?
  end
end
