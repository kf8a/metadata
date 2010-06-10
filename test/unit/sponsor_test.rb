require 'test_helper'

class SponsorTest < ActiveSupport::TestCase
  should_have_and_belong_to_many :protocols
  should_have_many :datasets
end
