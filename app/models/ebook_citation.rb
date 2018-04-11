# An Electronic Book
class EbookCitation < Citation
  private

  def bibtex_type
    :thesis
  end

  def endnote_type
    "Thesis\n"
  end
end
