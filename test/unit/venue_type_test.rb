require File.expand_path('../../test_helper',__FILE__)

class VenueTypeTest < ActiveSupport::TestCase

  should validate_presence_of :name
end
