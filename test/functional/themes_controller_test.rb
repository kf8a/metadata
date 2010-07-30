require File.dirname(__FILE__) + '/../test_helper'

class ThemesControllerTest < ActionController::TestCase
  context 'GET index' do
    setup do
      @theme = Factory.create(:theme)
      get :index
    end
    
    should assign_to :theme_roots
    should respond_with :success
  end
end
