require File.expand_path('../../test_helper',__FILE__)

class MeetingTest < ActiveSupport::TestCase
  should have_many(:abstracts)
  should belong_to :venue_type
  should validate_presence_of :venue_type
end



# == Schema Information
#
# Table name: meetings
#
#  id            :integer         not null, primary key
#  date          :date
#  title         :string(255)
#  announcement  :text
#  venue_type_id :integer
#  date_to       :date
#

