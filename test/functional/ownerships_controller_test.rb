require File.dirname(__FILE__) + '/../test_helper'

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
          post :create, :datatable => @datatable, :user_1 => @user, :user_count => 1
        end
        
        should redirect_to("the ownerships page") {ownerships_path}
      end
      
      context "and POST :create with multiple users" do
        setup do
          @user_1 = Factory.create(:email_confirmed_user)
          @user_2 = Factory.create(:email_confirmed_user)
          @user_3 = Factory.create(:email_confirmed_user)
          post :create, :datatable => @datatable, :user_1 => @user_1, :user_2 => @user_2, :user_3 => @user_3, :user_count => 3
        end
        
        should redirect_to("the ownerships page") {ownerships_path}
        should "make all the users own the datatable" do
          assert @user_1.owns?(@datatable)
          assert @user_2.owns?(@datatable)
          assert @user_3.owns?(@datatable)
        end
      end
      
      context "and POST :create with multiple users and datatables" do
        setup do
          @user_1 = Factory.create(:email_confirmed_user)
          @user_2 = Factory.create(:email_confirmed_user)
          @user_3 = Factory.create(:email_confirmed_user)
          @datatable_1 = Factory.create(:protected_datatable)
          @datatable_2 = Factory.create(:protected_datatable)
          @datatable_3 = Factory.create(:protected_datatable)
          post :create, :datatable_1 => @datatable_1, :datatable_2 => @datatable_2, :datatable_3 => @datatable_3, :user_1 => @user_1, :user_2 => @user_2, :user_3 => @user_3, :user_count => 3, :datatable_count => 3
        end
        
        should redirect_to("the ownerships page") {ownerships_path}
        should "make all the users own all the datatables" do
          assert @user_1.owns?(@datatable_1)
          assert @user_2.owns?(@datatable_1)
          assert @user_3.owns?(@datatable_1)
          assert @user_1.owns?(@datatable_2)
          assert @user_2.owns?(@datatable_2)
          assert @user_3.owns?(@datatable_2)
          assert @user_1.owns?(@datatable_3)
          assert @user_2.owns?(@datatable_3)
          assert @user_3.owns?(@datatable_3)
        end
      end
      
      context "and a user owns the datatable" do
        setup do
          @user = Factory.create(:email_confirmed_user)
          Factory.create(:ownership, 
                          :user => @user, 
                          :datatable => @datatable)
        end

        context "and DELETE :revoke ownership from the user" do
          setup do
            delete :revoke, :datatable => @datatable, :user => @user
          end
          
          should redirect_to("the datatable ownership page") {ownership_path(@datatable)}
        end
      end
    end
  end
end
