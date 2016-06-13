# ENW formatter for endnote RIS formatted citations
class ENW
  attr_accessor :citation

  def init(citation)
    @citation = citation
  end

  def to_enw
    "%0 #{endnote_type}#{title_to_enw}#{authors.to_enw}"\
    "#{editors.to_enw}#{endnote_publication_data}"\
    "#{volume}#{page_numbers_to_enw}#{pub_year_to_enw}"\
    "#{abstract_to_enw}#{doi_to_enw}"\
    "#{publisher_to_enw}#{publisher_url_to_enw}#{isbn_to_enw}#{city_to_enw}"\
    "#{accession_number}\n"
  end

  private

  def endnote_type
    @citation.book? ? "Book Section\n" : "Journal Article\n"
  end

  def endnote_publication_data
    if @citation.book?
      "\n%B #{@citation.publication}" + "\n%I #{@citation.publisher}" + "\n%C #{@citation.address}"
    else
      @citation.publication.present? ? "\n%J #{@citation.publication}" : ''
    end
  end

  def volume
    @citation.volume.present? ? "\n%V #{@citation.volume}" : ''
  end

  def accession_number
    "\n%M KBS.#{@citation.id}"
  end
end
