require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many :permissions
  should have_many :datatables
  
  context 'user roles' do
    should 'have an admin role' do
      assert User::ROLES.include?('admin')
    end
  end
end
