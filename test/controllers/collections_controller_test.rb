# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

# show collections
class CollectionsControllerTest < ActionController::TestCase
  context "GET :index" do
    setup do
      get :index
    end

    should respond_with :success
  end

  context "GET :show" do
    setup do
      @collection = FactoryBot.create(:collection)
      get :show, params: { id: @collection }
    end

    should respond_with :success
    should 'assign to collection' do
      assert_equal @collection, assigns(:collection)
    end
  end
end
