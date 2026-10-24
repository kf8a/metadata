require File.expand_path('../test_helper', __dir__)

class MembershipTest < ActiveSupport::TestCase
  should belong_to :sponsor
  should belong_to :user
end

# == Schema Information
#
# Table name: memberships
#
#  id         :integer         not null, primary key
#  sponsor_id :integer
#  user_id    :integer
#
