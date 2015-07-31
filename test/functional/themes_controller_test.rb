require File.expand_path('../../test_helper',__FILE__) 

class ThemesControllerTest < ActionController::TestCase

  context 'as admin user' do
    def setup
      signed_in_as_admin
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
      signed_in_as_admin
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

  context 'as anonymous' do
    def setup
      sign_out
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

      should redirect_to("the themes page") {sign_in_url}
      should_not set_flash
    end

    context 'POST update' do
      setup do
        @theme = FactoryGirl.create(:theme)
        post :update, id: @theme, theme: {name: "new title"}
      end

      should redirect_to('the themes page') {sign_in_url}
      should_not set_flash
    end
  end
end
