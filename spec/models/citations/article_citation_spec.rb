require 'rails_helper'

describe ArticleCitation do

  it 'should format correctly with 2 authors' do
    citation = ArticleCitation.new
    citation.authors << Author.new(sur_name: 'Loecke',
                                   given_name: 'T', middle_name: 'D',
                                   seniority: 1)

    citation.authors << Author.new(sur_name: 'Robertson',
                                   given_name: 'G', middle_name: 'P',
                                   seniority: 2)

    citation.title = 'Soil resource heterogeneity in the form of aggregated litter alters maize productivity'
    citation.publication = 'Plant and Soil'
    citation.volume = '325'
    citation.start_page_number = 231
    citation.ending_page_number = 241
    citation.pub_year = 2008
    citation.abstract = 'An abstract of the article.'
    citation.save

    result = 'Loecke, T. D. and G. P. Robertson. 2008. Soil resource heterogeneity in the form of aggregated litter alters maize productivity. Plant and Soil 325:231-241.'
    expect(citation.formatted).to eq result
  end

  it 'formats correctly with four authors' do
    citation = ArticleCitation.new
    citation.authors << Author.new(sur_name: 'Loecke',
                                   given_name: 'T', middle_name: 'D',
                                   seniority: 1)
    citation.authors << Author.new(sur_name: 'Hamilton',
                                   given_name: 'Steve',
                                   seniority: 2)
    citation.authors << Author.new(sur_name: 'Robertson',
                                   given_name: 'G', middle_name: 'P',
                                   seniority: 3)
    citation.authors << Author.new(sur_name: 'Klug',
                                   given_name: 'Mike',
                                   seniority: 4)
    citation.title = 'Soil resource heterogeneity in the form of aggregated litter alters maize productivity'
    citation.publication = 'Plant and Soil'
    citation.volume = '325'
    citation.start_page_number = 231
    citation.ending_page_number = 241
    citation.pub_year = 2008
    citation.abstract = 'An abstract of the article.'
    citation.save

    result = 'Loecke, T. D., S. Hamilton, G. P. Robertson, and M. Klug. 2008. Soil resource heterogeneity in the form of aggregated litter alters maize productivity. Plant and Soil 325:231-241.'
    short_result = 'Loecke, T. D., et.al.  2008. Soil resource heterogeneity in the form of aggregated litter alters maize productivity. Plant and Soil 325:231-241.'
    expect(citation.formatted).to eq short_result
    expect(citation.formatted(long: true)).to eq result
  end
end
