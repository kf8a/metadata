require File.expand_path('../../test_helper',__FILE__) 

class TemplatesControllerTest < ActionController::TestCase

  context 'as an admin user' do
    setup do
      signed_in_as_admin
    end
    context 'on GET to :index' do
      setup do 
        get :index
      end

      should respond_with :success
      should render_template :index
    end

    context 'on GET to :new' do
      setup do 
        get :new
      end

      should respond_with :success
      should render_template :new
    end

    context 'on GET to :show' do
      setup do
        template = FactoryGirl.create(:template)
        get :show, :id => template.id
      end

      should respond_with :success
      should render_template :show
    end

    context 'on POST to :create' do
      setup do 
        post :create, :template => {:controller => 'datatables', :action => 'show', :layout => 'p'}
      end

      should respond_with :redirect
    end
  end

end
