require 'test_helper'

class VenueTypeTest < ActiveSupport::TestCase
  fixtures :venue_types

  should validate_presence_of :name
end
