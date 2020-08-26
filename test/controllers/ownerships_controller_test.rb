require File.expand_path('../../test_helper',__FILE__)

class OwnershipsControllerTest < ActionController::TestCase

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

        should respond_with :redirect
      end
    end

    context ", signed in as non-admin" do
      setup do
        signed_in_as_normal_user
      end

      context "and GET :index" do
        setup do
          get :index
        end

        should respond_with :redirect
      end
    end

    context ', signed in as an admin' do
      setup do
        signed_in_as_admin
      end

      context 'and GET :index' do
        setup do
          get :index
        end

        should render_template 'index'
      end

      context 'and GET :show the datatable\'s owners' do
        setup do
          get :show, params: { id: @datatable }
        end

        should render_template 'show'
        should 'assign to' do
          assert_equal @datatable, assigns(:datatable)
        end
      end

      context 'and GET :show with invalid datatable' do
        setup do
          bad_id = @datatable.id
          @datatable.destroy
          assert_nil Datatable.find_by(:id, bad_id)
          get :show, params: { id: bad_id }
        end

        should redirect_to('the ownerships page') { ownerships_path }
      end

      context 'and GET :new permission for the datatable' do
        setup do
          get :new, params: { datatable: @datatable }
        end

        should respond_with :success
        should render_template 'new'
        should 'assign to datatable' do
          assert_equal @datatable, assigns(:datatable)
        end
        should 'assign to users' do
          assert assigns(:users)
        end
      end

      context 'and GET :new with no datatable param' do
        setup do
          get :new
        end

        should respond_with :success
        should render_template 'new'
      end

      context 'and POST :create with no users' do
        setup do
          post :create, params: { datatable: @datatable }
        end

        should render_template 'new'
      end

      context 'and POST :create with a valid user' do
        setup do
          @user = FactoryBot.create(:email_confirmed_user)
          post :create, params: { datatable: @datatable, users: [@user.id.to_s] }
        end

        should redirect_to('the ownership page') { ownership_path(id: @datatable.id) }
      end

      context "and POST :create with multiple users" do
        setup do
          @user1 = FactoryBot.create(:email_confirmed_user)
          @user2 = FactoryBot.create(:email_confirmed_user)
          @user3 = FactoryBot.create(:email_confirmed_user)
          post :create, params: { datatable: @datatable.id,
                                  users: [@user1.id.to_s, @user2.id.to_s, @user3.id.to_s] }
        end

        should redirect_to("the ownership page") { ownership_path(id: @datatable.id) }
        should "make all the users own the datatable" do
          assert @user1.owns?(@datatable)
          assert @user2.owns?(@datatable)
          assert @user3.owns?(@datatable)
        end
      end

      context "and POST :create with multiple users and datatables" do
        setup do
          @user1 = FactoryBot.create(:email_confirmed_user)
          @user2 = FactoryBot.create(:email_confirmed_user)
          @user3 = FactoryBot.create(:email_confirmed_user)
          @datatable1 = FactoryBot.create(:protected_datatable)
          @datatable2 = FactoryBot.create(:protected_datatable)
          @datatable3 = FactoryBot.create(:protected_datatable)
          post :create, params: { 'datatables' => [@datatable1.id.to_s, @datatable2.id.to_s, @datatable3.id.to_s],
                                  'users' => [@user1.id.to_s, @user2.id.to_s, @user3.id.to_s] }
        end

        should redirect_to("the ownerships page") { ownerships_path }
        should "make all the users own all the datatables" do
          assert @user1.owns?(@datatable1)
          assert @user2.owns?(@datatable1)
          assert @user3.owns?(@datatable1)
          assert @user1.owns?(@datatable2)
          assert @user2.owns?(@datatable2)
          assert @user3.owns?(@datatable2)
          assert @user1.owns?(@datatable3)
          assert @user2.owns?(@datatable3)
          assert @user3.owns?(@datatable3)
        end
      end

      context "and a user owns the datatable" do
        setup do
          @user = FactoryBot.create(:email_confirmed_user)
          FactoryBot.create(:ownership,
                            user: @user,
                            datatable: @datatable)
        end

        context "and DELETE :revoke ownership from the user" do
          setup do
            delete :revoke, params: { datatable: @datatable, user: @user }
          end

          should redirect_to("the datatable ownership page") { ownership_path(@datatable) }
        end
      end
    end
  end
end
