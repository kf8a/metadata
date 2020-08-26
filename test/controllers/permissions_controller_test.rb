require File.expand_path('../../test_helper',__FILE__)

class PermissionsControllerTest < ActionController::TestCase

  context "a protected and owned datatable" do
    setup do
      @datatable = FactoryBot.create(:protected_datatable)
      @owner = FactoryBot.create(:email_confirmed_user)
      FactoryBot.create(:ownership, user: @owner, datatable: @datatable)
    end

    context "and not signed in at all" do
      context "and GET :index" do
        setup do
          get :index
        end

        should respond_with :success
        should render_template 'index'
      end

      context "and GET :show the datatable's permissions" do
        setup do
          get :show, params: { id: @datatable }
        end

        should_not respond_with :success
        should redirect_to("the permissions index") {permissions_path}
      end
    end

    context ", signed in as non-owner" do
      setup do
        @nonowner = FactoryBot.create(:email_confirmed_user)
        sign_in(@nonowner)
      end

      context "and GET :new permission for the datatable" do
        setup do
          get :new, params: { datatable: @datatable }
        end

        should_not respond_with :success
        should redirect_to("the permissions index") {permissions_path}
      end

      context "and GET :show the datatable's permissions" do
        setup do
          get :show, params: { id: @datatable }
        end

        should_not respond_with :success
        should redirect_to("the permissions index") {permissions_path}
      end

      context "and DELETE :destroy the datatable's permissions" do
        setup do
          delete :destroy, params: { id: @datatable }
        end

        should_not respond_with :success
        should redirect_to("the permissions index") {permissions_path}
      end
    end

    context ', signed in as the owner' do
      setup do
        sign_in(@owner)
      end

      context 'and GET :index' do
        setup do
          get :index
        end

        should respond_with :success
        should render_template 'index'
      end

      context "and GET :show the datatable's permissions" do
        setup do
          get :show, params: { id: @datatable }
        end

        should respond_with :success
        should render_template 'show'
        should 'assign to datatable' do
          assert_equal @datatable, assigns(:datatable)
        end
        should 'assing to permitted_users' do
          assert assigns(:permitted_users)
        end
      end

      context "and GET :new permission for the datatable" do
        setup do
          get :new, params: { datatable: @datatable }
        end

        should respond_with :success
        should render_template 'new'
        should 'assign to datatable' do
          assert_equal @datatable, assigns(:datatable)
        end
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
          @user = FactoryBot.create(:email_confirmed_user)
          post :create, params: { datatable: @datatable, email: @user.email }
        end


        should redirect_to("the datatable permission page") {permission_path(@datatable.id)}
      end

      context "and POST :create with an invalid user email address" do
        setup do
          post :create, params: { datatable: @datatable, email: nil }
        end

        should render_template 'new'
      end

      context "and PUT :deny with a valid user email address" do
        setup do
          @user = FactoryBot.create(:email_confirmed_user)
          put :deny, params: { datatable: @datatable, email: @user.email }
        end

        should "make datatable not downloadable by user" do
          assert_not @datatable.can_be_downloaded_by?(@user)
        end
      end


      context "and a user has permission from the owner" do
        setup do
          @user = FactoryBot.create(:email_confirmed_user)
          FactoryBot.create(:permission,
                            user: @user,
                            owner: @owner,
                            datatable: @datatable,
                            decision: "approved")
        end

        context "and GET :show the datatable's permissions" do
          setup do
            get :show, params: { id: @datatable }
          end

          should 'have the right permitted users' do
            assert_equal [@user], assigns(:permitted_users)
          end
        end

        context "and POST :create permission for that user" do
          setup do
            post :create, params: { datatable: @datatable, email: @user.email }
          end

          should "make datatable downloadable by user" do
            assert @datatable.can_be_downloaded_by?(@user)
          end
        end

        context "and PUT :deny permission for that user" do
          setup do
            put :deny, params: { datatable: @datatable, email: @user.email }
          end

          should "make datatable not downloadable by user" do
            assert_not @datatable.can_be_downloaded_by?(@user)
          end
        end

        context "and DELETE :destroy permission from the user" do
          setup do
            delete :destroy, params: { id: @datatable.id, user: @user }
          end

          should redirect_to("the datatable permission page") { permission_path(@datatable) }
        end
      end
    end
  end

end
