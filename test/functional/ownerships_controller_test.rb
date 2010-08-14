require 'test_helper'

class OwnershipsControllerTest < ActionController::TestCase

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
      
      context "and GET :index" do
        setup do
          get :index
        end
        
        should respond_with :redirect
      end
    end
      
    context ", signed in as non-admin" do
      setup do
        @nonadmin = Factory.create(:email_confirmed_user, :role => nil)
        @controller.current_user = @nonadmin
      end
      
      context "and GET :index" do
        setup do
          get :index
        end
        
        should respond_with :redirect
      end      
    end
    
    context ", signed in as an admin" do
      setup do
        @admin = Factory.create(:email_confirmed_user, :role => 'admin')
        @controller.current_user = @admin
      end
      
      context "and GET :index" do
        setup do
          get :index
        end
        
        should render_template 'index'
      end
      
      context "and GET :show the datatable's owners" do
        setup do
          get :show, :id => @datatable
        end
        
        should render_template 'show'
        should assign_to(:datatable).with(@datatable)
      end
      
      context "and GET :show with invalid datatable param" do
        setup do
          get :show
        end
        
        should redirect_to("the ownerships index") {ownerships_path}
      end
      
      context "and GET :new permission for the datatable" do
        setup do
          get :new, :datatable => @datatable
        end
        
        should respond_with :success
        should render_template 'new'
        should assign_to(:datatable).with(@datatable)
        should assign_to(:users)
        should assign_to(:ownership)
      end
      
      context "and GET :new with no datatable param" do
        setup do
          get :new
        end
        
        should respond_with :success
        should render_template 'new'
        should_not assign_to(:datatable)
        should assign_to(:datatables)
        should assign_to(:users)
        should assign_to(:ownership)
      end
      
      context "and POST :create with a valid user" do
        setup do
          @user = Factory.create(:email_confirmed_user)          
          post :create, :datatable => @datatable, :user => @user
        end
        
        should redirect_to("the datatable ownership page") {ownership_path(@datatable)}
      end
      
      context "and a user owns the datatable" do
        setup do
          @user = Factory.create(:email_confirmed_user)
          Factory.create(:ownership, 
                          :user => @user, 
                          :datatable => @datatable)
        end

        context "and DELETE :destroy ownership from the user" do
          setup do
            delete :destroy, :datatable => @datatable, :user => @user
          end
          
          should redirect_to("the datatable ownership page") {ownership_path(@datatable)}
        end
      end
    end
  end
end
