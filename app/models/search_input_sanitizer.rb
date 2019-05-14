# Removed unsafe characters from the search input
class SearchInputSanitizer
  def self.sanitize(word)
    word.gsub(/\?|~|\\|@|(?:=>)/, '')
  end
end
