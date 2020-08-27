# frozen_string_literal: true

# Citation referring to a conference paper or poster
class ConferenceCitation < Citation
  private

  def bibtex_type
    :thesis
  end

  def endnote_type
    "Thesis\n"
  end
end
