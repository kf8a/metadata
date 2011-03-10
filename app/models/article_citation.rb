class ArticleCitation < Citation
  def as_endnote
    endnote = "%0 "
    endnote += "Journal Article\n"
    endnote += "%T #{title}\n"
    authors.each { |author| endnote += "%A #{author.formatted}\n" }
    editors.each { |editor| endnote += "%E #{editor.formatted}\n" }
    endnote += "%J #{publication}\n" unless publication.blank?
    endnote += "%V #{volume}\n" unless volume.blank?
    endnote += "%@ #{page_numbers}\n" unless page_numbers.blank?
    endnote += "%D #{pub_year}" unless pub_year.blank?
    endnote += "\n%X #{abstract}" unless abstract.blank?
    endnote
  end

  def formatted
    "#{author_and_year}. #{title}. #{publication} #{volume_and_page}".rstrip
  end

  private

  def bibtex_type
    :article
  end
end