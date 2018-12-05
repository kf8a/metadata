# frozen_string_literal: true

# A peer reviewed article
class ArticleCitation < Citation
  def formatted(options = {})
    "#{author_and_year(options)} #{title_and_punctuation}"\
    " #{journal} #{volume_and_page} #{annotation}".rstrip
  end

  def self.synopsis
    ''
  end

  def self.human_name
    'Journal Articles'
  end

  private

  def journal
    publication.presence || secondary_title
  end

  def bibtex_type
    :article
  end

  def endnote_type
    "Journal Article\n"
  end
end
