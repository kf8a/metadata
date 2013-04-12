require File.expand_path('../../test_helper',__FILE__)

class OwnershipsControllerTest < ActionController::TestCase

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

    context ", signed in as an admin" do
      setup do
        signed_in_as_admin
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
        should 'assign to' do
          assert_equal @datatable, assigns(:datatable)
        end
      end

      context "and GET :show with invalid datatable" do
        setup do
          bad_id = @datatable.id
          @datatable.destroy
          assert_nil Datatable.find_by_id(bad_id)
          get :show, :id => bad_id
        end

        should redirect_to("the ownerships page") {ownerships_path}
      end

      context "and GET :new permission for the datatable" do
        setup do
          get :new, :datatable => @datatable
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

      context "and GET :new with no datatable param" do
        setup do
          get :new
        end

        should respond_with :success
        should render_template 'new'
      end

      context "and POST :create with no users" do
        setup do
          post :create, :datatable => @datatable
        end

        should render_template 'new'
      end
      context "and POST :create with a valid user" do
        setup do
          @user = FactoryGirl.create(:email_confirmed_user)
          post :create, :datatable => @datatable, 'users' => ["#{@user.id}"]
        end

        should redirect_to("the ownership page") {ownership_path(:id => @datatable.id)}
      end

      context "and POST :create with multiple users" do
        setup do
          @user_1 = FactoryGirl.create(:email_confirmed_user)
          @user_2 = FactoryGirl.create(:email_confirmed_user)
          @user_3 = FactoryGirl.create(:email_confirmed_user)
          post :create, :datatable => @datatable.id, 'users' => ["#{@user_1.id}", "#{@user_2.id}", "#{@user_3.id}"]
        end

        should redirect_to("the ownership page") {ownership_path(:id => @datatable.id)}
        should "make all the users own the datatable" do
          assert @user_1.owns?(@datatable)
          assert @user_2.owns?(@datatable)
          assert @user_3.owns?(@datatable)
        end
      end

      context "and POST :create with multiple users and datatables" do
        setup do
          @user_1 = FactoryGirl.create(:email_confirmed_user)
          @user_2 = FactoryGirl.create(:email_confirmed_user)
          @user_3 = FactoryGirl.create(:email_confirmed_user)
          @datatable_1 = FactoryGirl.create(:protected_datatable)
          @datatable_2 = FactoryGirl.create(:protected_datatable)
          @datatable_3 = FactoryGirl.create(:protected_datatable)
          post :create, 'datatables' => ["#{@datatable_1.id}", "#{@datatable_2.id}", "#{@datatable_3.id}"], 'users' => ["#{@user_1.id}", "#{@user_2.id}", "#{@user_3.id}"]
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
          @user = FactoryGirl.create(:email_confirmed_user)
          FactoryGirl.create(:ownership,
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
