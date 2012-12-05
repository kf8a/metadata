require File.expand_path('../../test_helper',__FILE__) 

class PermissionsControllerTest < ActionController::TestCase

  context "a protected and owned datatable" do
    setup do
      @datatable = FactoryGirl.create(:protected_datatable)
      @owner = FactoryGirl.create(:email_confirmed_user)
      FactoryGirl.create(:ownership, :user => @owner, :datatable => @datatable)
    end

    context "and not signed in at all" do
      setup do
        @controller.current_user = nil
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
          get :show, :id => @datatable
        end

        should_not respond_with :success
        should redirect_to("the permissions index") {permissions_path}
      end
    end

    context ", signed in as non-owner" do
      setup do
        @nonowner = FactoryGirl.create(:email_confirmed_user)
        @controller.current_user = @nonowner
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
          get :show, :id => @datatable
        end

        should_not respond_with :success
        should redirect_to("the permissions index") {permissions_path}
      end

      context "and DELETE :destroy the datatable's permissions" do
        setup do
          delete :destroy, :id => @datatable
        end

        should_not respond_with :success
        should redirect_to("the permissions index") {permissions_path}
      end
    end

    context ", signed in as the owner" do
      setup do
        sign_in_as(@owner)
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
          get :show, :id => @datatable
        end

        should respond_with :success
        should render_template 'show'
        should assign_to(:datatable).with(@datatable)
        should assign_to(:permitted_users)
      end

      context "and GET :new permission for the datatable" do
        setup do
          get :new, :datatable => @datatable
        end

        should respond_with :success
        should render_template 'new'
        should assign_to(:datatable).with(@datatable)
      end

      context "and GET :new with invalid datatable param" do
        setup do
          get :new
        end

        should_not respond_with :success
        should redirect_to("the permissions index") {permissions_path}
      end

      context "and POST :create with a valid user email address" do
        setup do
          @user = FactoryGirl.create(:email_confirmed_user)          
          post :create, :datatable => @datatable, :email => @user.email
        end

        should redirect_to("the datatable permission page") {permission_path(@datatable)}
      end

      context "and POST :create with an invalid user email address" do
        setup do
          post :create, :datatable => @datatable, :email => nil
        end

        should render_template 'new'
      end

      context "and PUT :deny with a valid user email address" do
        setup do
          @user = FactoryGirl.create(:email_confirmed_user)
          put :deny, :datatable => @datatable, :email => @user.email
        end

        should "make datatable not downloadable by user" do
          assert !@datatable.can_be_downloaded_by?(@user)
        end
      end


      context "and a user has permission from the owner" do
        setup do
          @user = FactoryGirl.create(:email_confirmed_user)
          FactoryGirl.create(:permission, 
                          :user => @user, 
                          :owner => @owner, 
                          :datatable => @datatable)
        end

        context "and GET :show the datatable's permissions" do
          setup do
            get :show, :id => @datatable
          end

          should 'have the right permitted users' do
            assert_equal [@user], assigns(:permitted_users)
          end
        end

        context "and POST :create permission for that user" do
          setup do
            post :create, :datatable => @datatable, :email => @user.email
          end

          should "make datatable downloadable by user" do
            assert @datatable.can_be_downloaded_by?(@user)
          end
        end

        context "and PUT :deny permission for that user" do
          setup do
            put :deny, :datatable => @datatable, :email => @user.email
          end

          should "make datatable not downloadable by user" do
            assert !@datatable.can_be_downloaded_by?(@user)
          end
        end

        context "and DELETE :destroy permission from the user" do
          setup do
            delete :destroy, :id => @datatable.id, :user => @user
          end
          
          should redirect_to("the datatable permission page") {permission_path(@datatable)}
        end
      end
    end
  end

end
