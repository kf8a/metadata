require 'test_helper'

class TemplatesControllerTest < ActionController::TestCase
 
  context 'on GET to :index' do
    setup do 
      get :index
    end
    
    should respond_with :success
    should assign_to :templates
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
      template = Factory.create(:template)
      get :show, :id => template.id
    end
    
    should respond_with :success
    should render_template :show
  end
  
  context 'on POST to :create' do
    setup do 
      post :create, {:controller => 'datatables', :action => 'show', :layout => 'p'}
    end
    
    should respond_with :redirect
  end
  
end
