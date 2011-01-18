require File.expand_path('../../test_helper',__FILE__) 

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

      context "POST :create" do
        setup do
          post :create, :datatable => @datatable
        end
        
        should "not create a permission request" do
          assert_nil PermissionRequest.find_by_datatable_id_and_user_id(@datatable, @user)
        end
      end
    end
    
    context "and signed in as a valid user" do
      setup do
        @user = Factory.create(:email_confirmed_user)
        @controller.current_user = @user
      end
      
      context "POST :create" do
        setup do
          post :create, :datatable => @datatable
        end
        
        should "create a permission request" do
          assert PermissionRequest.find_by_datatable_id_and_user_id(@datatable, @user)
        end
      end
    end
  end
end
