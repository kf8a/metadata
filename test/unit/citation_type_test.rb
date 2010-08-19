require File.dirname(__FILE__) + '/../test_helper'

class CitationTypeTest < ActiveSupport::TestCase  
  should have_many :citations

end
