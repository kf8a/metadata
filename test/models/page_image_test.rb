require File.expand_path('../../test_helper', __FILE__)

class PageImageTest < ActiveSupport::TestCase
  should belong_to :page
end
