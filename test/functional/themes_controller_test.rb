require 'test_helper'

class ThemesControllerTest < ActionController::TestCase
  context 'GET index' do
    setup do
      @theme = Factory.create(:theme)
      get :index
    end
    
    should_assign_to :theme_root
    should_respond_with :success
  end
end
