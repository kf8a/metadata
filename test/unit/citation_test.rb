require File.dirname(__FILE__) + '/../test_helper'

class CitationTest < ActiveSupport::TestCase
  should belong_to :citation_type
  should have_many :authors
  should belong_to :website

end
