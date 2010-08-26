require File.dirname(__FILE__) + '/../test_helper'

class SponsorsControllerTest < ActionController::TestCase
 
  context 'GET: show' do
    setup do
      sponsor = Factory.create :sponsor, :data_use_statement => 'smoke em if you got em'
      get :show, :id => sponsor
    end
    
    should respond_with :success
    
    should 'contain the data_use_statement' do
      assert_select "p", "smoke em if you got em"
    end
  end
  
end
