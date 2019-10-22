# Removed unsafe characters from the search input
class SearchInputSanitizer
  def self.sanitize(word)
    word.tr('^A-Za-z0-9', ' ').squeeze(' ').strip()
  end
end
