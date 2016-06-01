# create a new citation if given a doi
# goes out and fetches the citation details and pdf
class CitationFactory
  def self.from_doi(doi_string)
    Citation.new
  end
end
