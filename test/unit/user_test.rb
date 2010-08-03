require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many :permissions
  should have_many :datatables
  
  context 'a user' do
    should 'include admin role' do
      assert User::ROLES.include?('admin')
    end
  end
  
  context "allowed(datatable) function" do
    context "a restricted datatable" do
      setup do
        @datatable = Factory.create(:restricted_datatable)
      end
      
      context "an admin user" do
        setup do
          @admin = Factory.create(:admin_user)
        end
        
        should "be allowed to download datatable" do
          assert @admin.allowed(@datatable)
        end
      end
      
    end
  end
end
