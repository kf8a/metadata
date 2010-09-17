require File.dirname(__FILE__) + '/../test_helper'

class CollectionsControllerTest < ActionController::TestCase

  context "GET :index" do
    setup do
      get :index
    end
    
    should respond_with :success
    should assign_to :collections
  end
  
  context "GET :show" do
    setup do
      @collection = Factory.create(:collection)
      get :show, :id => @collection
    end
    
    should respond_with :success
    should assign_to(:collection).with(@collection)
    should assign_to(:values)
  end
  
  context 'GET :show with keywords' do
    setup do
      @collection = Factory.create(:collection)
      @collection.datatable.keyword_list = 'some words'
      get :show, :id => @collection
    end
    
    should respond_with :success
  end

end
