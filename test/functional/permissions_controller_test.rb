require 'test_helper'

class PermissionsControllerTest < ActionController::TestCase

  context "a protected and owned datatable" do
    setup do
      @datatable = Factory.create(:protected_datatable)
      @owner = Factory.create(:email_confirmed_user)
      Factory.create(:ownership, :user => @owner, :datatable => @datatable)
    end
    
    context ", signed in as non-owner" do
      setup do
        @nonowner = Factory.create(:email_confirmed_user)
        @controller.current_user = @nonowner
      end
      
      context "and GET :index" do
        setup do
          get :index
        end
        
        should respond_with :success
        should render_template 'index'
      end
      
      context "and GET :new permission for the datatable" do
        setup do
          get :new, :datatable => @datatable
        end
        
        should_not respond_with :success
        should redirect_to("the permissions index") {permissions_path}
      end      
      
      context "and GET :show the datatable's permissions" do
        setup do
          get :show, :datatable => @datatable
        end
        
        should_not respond_with :success
        should redirect_to("the permissions index") {permissions_path}
      end
      
    end
    
    context ", signed in as the owner" do
      setup do
        @controller.current_user = @owner
      end
      
      context "and GET :index" do
        setup do
          get :index
        end
        
        should respond_with :success
        should render_template 'index'
      end
      
      context "and GET :show the datatable's permissions" do
        setup do
          get :show, :datatable => @datatable
        end
        
        should respond_with :success
        should render_template 'show'
      end
      
      context "and GET :show with invalid datatable param" do
        setup do
          get :show
        end
        
        should_not respond_with :success
        should redirect_to("the permissions index") {permissions_path}
      end

      
      context "and GET :new permission for the datatable" do
        setup do
          get :new, :datatable => @datatable
        end
        
        should respond_with :success
        should render_template 'new'
      end
      
      context "and GET :new with invalid datatable param" do
        setup do
          get :new
        end
        
        should_not respond_with :success
        should redirect_to("the permissions index") {permissions_path}
      end
    end
  end

end
