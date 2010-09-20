require 'test_helper'

class InvitesControllerTest < ActionController::TestCase

  context 'as an admin' do
    setup do 
      @controller.current_user = Factory.create :admin_user
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
        @invite = Factory.create :invite
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
        invite = Factory.create :invite
        get :edit, :id => invite
      end

      should respond_with(:success)
    end

    context 'POST :create' do
      setup do
        post :create, :invite => { }
      end

      should redirect_to('the invite_path') { invite_path(assigns(:invite)) }
    end

    context 'PUT :update' do
      setup do 
        invite = Factory.create :invite
        put :update, :id => invite, :invite => {}
      end

      should redirect_to('the invite_path') { invite_path(assigns(:invite)) }
    end

    context 'DELETE :destroy' do
      setup do
        @count = Invite.count
        invite = Invite.first
        delete :destroy, :id => invite
      end

      should 'remove one invite' do
        assert Invite.count == @count - 1
      end
    end
  end

end
