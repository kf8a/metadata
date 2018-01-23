# A citation that represents a non peer reviewed report
class ReportCitation < Citation
  def formatted(options = {})
    "#{author_and_year(options)} #{title_and_punctuation} #{editor_string}#{publication_string}#{volume_and_page}#{publisher_string}#{address_and_city}."
  end

  private

  def bibtex_type
    :report
  end

  def endnote_type
    "Report\n"
  end

  def publisher_string
    return '' if publisher.blank?
    publisher + ', '
  end

  def publication_string
    return '' if publication.blank?
    publication + '. '
  end

  def address_and_city
    return '' if city.blank?
    city
  end
end
