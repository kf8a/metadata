class ConvertCitationsToType < ActiveRecord::Migration[4.2]
  def self.up
    book_type = CitationType.find_by_name('book')
    Citation.all.each do |citation|
      next unless citation.class == Citation
      if citation.citation_type == book_type
        citation.type = 'BookCitation'
      else
        citation.type = 'ArticleCitation'
      end
      citation.save
    end
  end

  def self.down
    book_type = CitationType.find_by_name('book')
    article_type = CitationType.find_by_name('article')
    Citation.all.each do |citation|
      next if citation.class == Citation
      if citation.class == BookCitation
        citation.citation_type = book_type
      else
        citation.citation_type = article_type
      end
      citation.save
    end
  end
end
