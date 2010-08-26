require File.dirname(__FILE__) + '/../../test_helper'

class ApplicationHelperTest < ActionView::TestCase
  
  def test_textilize
    assert_equal textilize("<p>This *is* a test</p>"), "<p>This <strong>is</strong> a test</p>"
  end
  
  def test_strip_html_tags
    assert_equal strip_html_tags("<p>This is a test</p>"), "This is a test"
  end
  
  def test_lter_roles
    assert lter_roles
    assert_kind_of Array, lter_roles
  end
end