require File.expand_path('../../test_helper',__FILE__) 

class ThemesControllerTest < ActionController::TestCase

  def setup

    #TODO test with admin and non admin users
    @controller.current_user = FactoryGirl.create :admin_user
  end

  context 'GET index' do
    setup do
      @theme = FactoryGirl.create(:theme)
      get :index
    end

    should respond_with :success
  end

  context "POST create" do
    setup do
      post :create, theme: {name: "One theme"}
    end

    should redirect_to("the themes page") {themes_url}
    should set_flash
  end

  context 'POST update' do
    setup do
      @theme = FactoryGirl.create(:theme)
      post :update, id: @theme, theme: {name: "new title"}
    end

    should redirect_to('the themes page') {themes_url}
    should set_flash
  end
end
