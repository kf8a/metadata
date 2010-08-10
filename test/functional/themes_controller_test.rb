require File.dirname(__FILE__) + '/../test_helper'

class ThemesControllerTest < ActionController::TestCase

  def setup

    #TODO test with admin and non admin users
    @controller.current_user = User.new(:role => 'admin')
  end

  context 'GET index' do
    setup do
      @theme = Factory.create(:theme)
      get :index
    end
    
    should assign_to :theme_roots
    should respond_with :success
  end
  
  context "POST create" do
    setup do
      post :create
    end
    
    should assign_to :theme
    should redirect_to("the themes page") {themes_url}
    should set_the_flash
  end
end
