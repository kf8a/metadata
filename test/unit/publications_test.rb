require File.dirname(__FILE__) + '/../test_helper'

class PublicationsTest < ActiveSupport::TestCase
  fixtures :publications
  
  def test_empty_citation
    p = Publication.new
  end
end
