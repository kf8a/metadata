require 'test_helper'

class CitationsControllerTest < ActionController::TestCase
 
  context 'GET :index from anonymous user' do
    setup do
      get :index
    end
    
    should respond_with(:success)
    should assign_to :citations

  end
  
  context 'GET :index from a signed in user' do
    setup do
      @controller.current_user = Factory :user
      get :index
    end
    
    should respond_with :success
    should assign_to :citations
    
    should 'have a PDF download link'
  end
  
end
