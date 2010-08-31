require 'test_helper'

class CollectionsControllerTest < ActionController::TestCase

  context "GET :index" do
    setup do
      get :index
    end
    
    should respond_with :success
  end
  
  context "GET :show" do
    setup do
      @collection = Factory.create(:collection)
      get :show, :id => @collection
    end
    
    should respond_with :success
  end
end
