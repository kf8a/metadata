require File.expand_path('../../test_helper',__FILE__) 

class CitationTypeTest < ActiveSupport::TestCase  
  should have_many :citations
end
