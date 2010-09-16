require File.dirname(__FILE__) + '/../test_helper'

class PermissionRequestsControllerTest < ActionController::TestCase

  context "a protected and owned datatable" do
    setup do
      @datatable = Factory.create(:protected_datatable)
      @owner = Factory.create(:email_confirmed_user)
      Factory.create(:ownership, :user => @owner, :datatable => @datatable)
    end
    
    context "and not signed in at all" do
      setup do
        @controller.current_user = nil
      end

      context "GET :new" do
        setup do
          get :new, :datatable => @datatable
        end
        
        should_not respond_with :success
      end
      
      context "POST :create" do
        setup do
          post :create, :datatable => @datatable
        end
        
        should_not respond_with :success
      end
    end
    
    context "and signed in as a valid user" do
      setup do
        @user = Factory.create(:email_confirmed_user)
        @controller.current_user = @user
      end
      
      context "GET :new" do
        setup do
          get :new, :datatable => @datatable
        end
        
        should respond_with :success
        should assign_to(:datatable).with(@datatable)
      end
      
      context "POST :create" do
        setup do
          post :create, :datatable => @datatable
        end
        
        should respond_with :success
        should "create a permission request" do
          assert PermissionRequest.find_by_datatable_id_and_user_id(@datatable, @user)
        end
      end
    end
  end
end
