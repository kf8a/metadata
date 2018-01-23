# frozen_string_literal: true

# A data citation
class DataCitation < Citation
  def formatted(options = {})
    "#{author_and_year(options)} #{title_and_punctuation}"\
    " #{journal} #{volume_and_page} #{annotation}".rstrip
  end

  private

  def journal
    publication.blank? ? secondary_title : publication
  end

  def bibtex_type
    :data
  end

  def endnote_type
    "Data Publication\n"
  end
end
