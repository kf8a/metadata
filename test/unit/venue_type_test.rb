require File.expand_path('../../test_helper',__FILE__) 

class VenueTypeTest < ActiveSupport::TestCase
  fixtures :venue_types

  should validate_presence_of :name
end
