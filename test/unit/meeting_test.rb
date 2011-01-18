require File.expand_path('../../test_helper',__FILE__) 

class MeetingTest < ActiveSupport::TestCase
  fixtures :meetings

  should validate_presence_of :venue_type
end
