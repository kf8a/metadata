require 'test_helper'

class TemplatesControllerTest < ActionController::TestCase
 
  context 'on GET to :index' do
    setup do 
      get :index
    end
    
    should_respond_with :success
    should_assign_to :templates
    should_render_template :index
  end
  
  context 'on GET to :new' do
    setup do 
      get :new
    end
    
    should_respond_with :success
    should_render_template :new
  end
  
  context 'on POST to :create' do
    setup do 
      post :create
    end
  end
  
end
