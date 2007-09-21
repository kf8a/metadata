require File.dirname(__FILE__) + '/../test_helper'

class PublicationsTest < Test::Unit::TestCase
  fixtures :publications

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_empty_citation
    p = Publication.new
  end
end
