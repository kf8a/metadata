require File.expand_path('../test_helper', __dir__)

class PageImageTest < ActiveSupport::TestCase
  should belong_to :page
end
