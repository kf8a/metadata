require 'test_helper'

class PermissionRequestsControllerTest < ActionController::TestCase
  # Replace this with your real tests.

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
          post :create, :permission_request => {:datatable_id => @datatable}
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
        should assign_to(:permission_request)
      end
      
      context "POST :create" do
        setup do
          post :create, :permission_request => {:datatable_id => @datatable.id, :user_id => @user.id}
        end
        
        should respond_with :success
        should "create a permission request" do
          assert PermissionRequest.find_by_datatable_id_and_user_id(@datatable, @user)
        end
      end
    end
  end
end
