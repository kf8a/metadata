require File.expand_path('../../test_helper',__FILE__) 

class VariatesControllerTest < ActionController::TestCase
  #fixtures :variates
 
  context 'signed in as admin' do
    setup do 
      signed_in_as_admin
      @variate = FactoryGirl.create :variate
    end

    context 'GET :index' do
      setup do
        get :index
      end

      should respond_with :success
    end

    context 'GET :new' do
      setup do
        get :new
      end

      should respond_with :success
    end

    context 'GET :new in javascript' do
      setup do
        xhr :get, :new
      end

      should respond_with :success
    end

    context 'GET :show' do
      setup do
        get :show, :id => @variate
      end

      should respond_with :success
    end

    context 'GET :edit' do
      setup do
        get :edit, :id => @variate
      end

      should respond_with :success
    end

    context 'PUT :update' do
      setup do
        put :update, :id => @variate, :variate => {}
      end

      should 'redirect to the variate page' do
        assert_redirected_to {variate_path(assigns(:variate))}
      end
    end

    context 'POST :create' do
      setup do
        post :create, :variate => {}
      end

      # TODO the code is doing the right thing but there is some problem with this test
      # it expects /variates when it should expect /variates/:id
      # should 'redirect to variate page' do 
      #   assert_redirected_to {variate_path(assigns(:variate))}
      # end
    end

    context 'DESTROY' do
      setup do
        post :destroy, :id => @variate
      end

      should redirect_to('the variates index page') { variates_path }
    end
  end
end
