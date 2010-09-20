require 'test_helper'

class SponsorRoleTest < ActiveSupport::TestCase

  should belong_to :sponsor
  should belong_to :user
  
end
