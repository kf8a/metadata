require File.expand_path('../../test_helper',__FILE__) 

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
      @collection = FactoryGirl.create(:collection)
      get :show, :id => @collection
    end

    should respond_with :success
    should assign_to(:collection).with(@collection)
  end
end
