require File.expand_path('../../test_helper',__FILE__) 

class PagesControllerTest < ActionController::TestCase

  context 'as an admin' do
    setup do
      @controller.current_user =  Factory.create :admin_user
    end
    
    context 'GET :show' do
      setup do 
        @page = Factory.create :page
        get :show, :id => @page
      end

      should respond_with :success
    end

    context 'GET :index' do
      setup do
        get :index
      end

      should respond_with :bad_request
    end

    context 'GET :new' do
      setup do
        get :new
      end

      should respond_with :success
    end

    context 'POST :update' do
      setup do
        @page = Factory.create :page
        post :update, :id => @page, :title => 'something else'
      end

      should assign_to(:page)
      should redirect_to('the show page') {page_url(assigns(:page))}
    end

    context 'PUT :create' do
      setup do
        put :create
      end

      should assign_to(:page)
      should redirect_to("the show page") {page_url(assigns(:page))}
    end

    context 'DELETE :delete' do
    end
  end
  
  context 'as a regular user' do
    setup do
      @controller.current_user = nil
    end
    
    context 'GET: index' do
      setup do
        get :index
      end
      
      should redirect_to("the sign in page") {sign_in_url}
    end
    
    context 'GET :show' do
      setup do
        @page = Factory.create(:page)
        get :show, :id => @page
      end
      
      should respond_with :success
    end
    
    context 'PUT :create' do
      setup do
        put :create
      end
      
      should redirect_to("the sign in page") {sign_in_url}
    end
    
    context 'POST :update' do
      setup do
        @page = Factory.create :page
        post :update, :id => @page, :title => 'something else'
      end
      
      should redirect_to("the sign in page") {sign_in_url}
    end
  end
end
