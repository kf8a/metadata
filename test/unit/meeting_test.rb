require File.dirname(__FILE__) + '/../test_helper'

class MeetingTest < ActiveSupport::TestCase
  fixtures :meetings

  should validate_presence_of :venue_type
end
