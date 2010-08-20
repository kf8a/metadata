require 'test_helper'

class CitationsControllerTest < ActionController::TestCase

  context 'anonymous user' do
    setup do
      @controller.current_user = nil
    end

    context 'GET :index from anonymous user' do
      setup do
        get :index
      end

      should respond_with :success
      should assign_to :citations

    end

    context 'POST: create' do
      setup do
        post :create 
      end

      should respond_with :forbidden
    end

  end

  context 'signed in user' do
    
    setup do
      @controller.current_user = Factory :user
    end
    
    context 'GET :index' do
      setup do
        get :index
      end

      should respond_with :success
      should assign_to :citations

      should 'have a PDF download link'
    end

    context 'POST: create' do
      setup do
        post :create
      end

      should respond_with :forbidden
    end
    
  end

  context 'signed in as admin' do
    
    setup do
      @controller.current_user = Factory :user, :role => 'admin'
    end

    context 'GET :index' do
      setup do
        get :index
      end

      should respond_with :success
      should assign_to :citations

      should 'have a PDF download link'
    end

    context 'POST: create' do
      setup do
        post :create
      end

      should respond_with :redirect
      should redirect_to('the citation index page') { citation_url(assigns(:citation)) }
    end
  end
end
