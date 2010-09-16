require File.dirname(__FILE__) + '/../test_helper'

class PageImageTest < ActiveSupport::TestCase
 
  should belong_to :page
  
  should have_attached_file(:image)
end
