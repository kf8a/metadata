require File.expand_path('../../test_helper',__FILE__)

class VenueTypeTest < ActiveSupport::TestCase

  should validate_presence_of :name
end

# == Schema Information
#
# Table name: venue_types
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :text
#

