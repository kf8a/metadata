# Removed unsafe characters from the search input
class SearchInputSanitizer
  def self.sanitize(word)
    word.sub(/\?|~|\\|\*|@|(?:=>)/, '')
  end
end
