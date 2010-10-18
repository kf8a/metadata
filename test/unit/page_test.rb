require File.expand_path('../../test_helper',__FILE__) 

class PageTest < ActiveSupport::TestCase
  should have_many :page_images
  should_accept_nested_attributes_for :page_images
end
