require File.dirname(__FILE__) + '/../test_helper'

class PageTest < ActiveSupport::TestCase
  should have_many :page_images
  should_accept_nested_attributes_for :page_images
end
