require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  should belong_to :sponsor
  should belong_to :user
end
