require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many :permissions
  should have_many :datatables
  should have_many :owned_datatables
end
