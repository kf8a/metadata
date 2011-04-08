require File.expand_path('../../test_helper',__FILE__)

class InvitesControllerTest < ActionController::TestCase

  context 'as an admin' do
    setup do
      signed_in_as_admin
      @invite = Factory.create :invite
    end

    context 'GET :index' do
      setup do
        get :index
      end

      should respond_with :success
      should assign_to(:invites)
    end

    context 'GET :show' do
      setup do
        get :show, :id => @invite
      end

      should respond_with(:success)
    end

    context 'GET :new' do
      setup do
        get :new
      end

      should respond_with(:success)
    end

    context 'GET :edit' do
      setup do
        get :edit, :id => @invite
      end

      should respond_with(:success)
    end

    context 'POST :create' do
      setup do
        post :create, :invite => { :email => Factory.next(:email) }
      end

      should 'redirect to show page' do
        assert redirect_to invite_path(assigns(:invite))
      end

    end

    context 'POST :create with invalid attributes' do
      setup do
        post :create, :invite => { :email => nil }
      end

      should render_template 'new'
    end

    context 'PUT :update' do
      setup do
        put :update, :id => @invite, :invite => {}
      end

      should 'redirect to the show page' do
        assert redirect_to invite_path(assigns(:invite))
      end
    end

    context 'PUT :update with invalid attributes' do
      setup do
        put :update, :id => @invite, :invite => { :email => nil }
      end

      should render_template 'edit'
    end

    context 'DELETE :destroy' do
      setup do
        @count = Invite.count
        delete :destroy, :id => @invite
      end

      should 'remove one invite' do
        assert Invite.count == @count - 1
      end
    end
  end

end
