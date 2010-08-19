require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  setup do
    @user = Factory.create(:user)
  end
  
  should have_many :permissions
  should have_many :datatables
  
  should validate_uniqueness_of(:email).case_insensitive
  
  context 'a user' do
    setup do
      @user = Factory :user
    end
    
    should 'include admin role' do
      assert User::ROLES.include?('admin')
    end
    
    should 'respond to has_permission_from' do
      assert @user.respond_to?('has_permission_from')
    end
  end
  
  context "allowed(datatable) function" do
    context "with a protected and owned datatable" do
      setup do
        @datatable = Factory.create(:protected_datatable)
        @owner = Factory.create(:email_confirmed_user)
        Factory.create(:ownership, :user => @owner, :datatable => @datatable)
      end
      
      context "an admin user" do
        setup do
          @admin = Factory.create(:admin_user)
        end
        
        should "be allowed to download datatable" do
          assert @admin.allowed(@datatable)
        end
      end
      
      context "the owner" do
        should "be allowed to download datatable" do
          assert @owner.allowed(@datatable)
        end
      end
      
      context "someone with permission" do
        setup do
          @user = Factory.create(:email_confirmed_user)
          Factory.create(:permission, :user => @user, :datatable => @datatable, :owner => @owner)
        end
        
        should "be allowed to download datatable" do
          assert @user.allowed(@datatable)
        end
      end
      
      context "someone without permission" do
        setup do
          @user = Factory.create(:email_confirmed_user)
        end
        
        should "not be allowed to download datatable" do
          assert ! @user.allowed(@datatable)
        end
      end
    end
  end
  
  context "the owns(datatable) function" do
    context "with a protected datatable" do
      setup do
        @datatable = Factory.create(:protected_datatable)
      end
      
      context "and an owner" do
        setup do
          @owner = Factory.create(:email_confirmed_user)
          Factory.create(:ownership, :user => @owner, :datatable => @datatable)
        end
        
        should "own the datatable" do
          assert @owner.owns(@datatable)
        end
      end
      
      context "and a non-owner" do
        setup do
          @nonowner = Factory.create(:email_confirmed_user)
        end
        
        should "not own the datatable" do
          assert ! @nonowner.owns(@datatable)
        end
      end
    end
  end
  
end
