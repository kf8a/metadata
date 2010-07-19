require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many :permissions
  should have_many :datatables
  
  context 'a user' do
    should 'include admin role' do
      assert User::ROLES.include?('admin')
    end
  end
end
