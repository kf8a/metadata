require File.expand_path('../../test_helper',__FILE__)

class MeetingTest < ActiveSupport::TestCase
  should have_many(:abstracts)
  should belong_to :venue_type
  should validate_presence_of :venue_type
end
