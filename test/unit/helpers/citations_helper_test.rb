require File.dirname(__FILE__) + '/../../test_helper'

class CitationsHelperTest < ActionView::TestCase
  
  def setup
    @citation = Citation.new
  end
  
  def test_formatted_as_default
    assert formatted_as_default(@citation).kind_of?(String)
  end
end
