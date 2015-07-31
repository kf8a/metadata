require File.expand_path('../../../test_helper',__FILE__) 

class ApplicationHelperTest < ActionView::TestCase
  
  def test_textilize
    assert_equal textilize("<p>This *is* a test</p>"), "<p>This <strong>is</strong> a test</p>"
  end
  
  def test_texilize_with_nil
    assert_equal textilize(nil), ''
  end
  
  def test_strip_html_tags
    assert_equal strip_html_tags("<p>This is a test</p>"), "This is a test"
  end
  
  def test_lter_roles
    assert lter_roles
    assert_kind_of Array, lter_roles.to_a
  end
end
