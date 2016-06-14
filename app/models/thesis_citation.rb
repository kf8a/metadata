# A citation representing a thesis or dissertation
class ThesisCitation < Citation
  def formatted(options = {})
    "#{author_and_year(options)} #{title_and_punctuation}"\
    " #{series_title}, #{publisher}#{address_and_city}."
  end

  private

  def address_and_city
    if address.present? && city.present?
      ", #{address} #{city}"
    elsif address.present?
      ", #{address}"
    elsif city.present?
      ", #{city}"
    end
  end

  def bibtex_type
    :thesis
  end

  def endnote_type
    "Thesis\n"
  end
end
