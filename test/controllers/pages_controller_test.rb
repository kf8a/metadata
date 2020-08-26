require File.expand_path('../../test_helper',__FILE__)

class PagesControllerTest < ActionController::TestCase

  context 'as an admin' do
    setup do
      signed_in_as_admin
    end

    context 'GET :show' do
      setup do
        @page = FactoryBot.create :page, { title: "SHOW page" }
        get :show, params: { id: @page }
      end

      should respond_with :success
    end

    context 'GET :index' do
      setup do
        get :index
      end

      should respond_with :bad_request
    end

    context 'GET :new' do
      setup do
        get :new
      end

      should respond_with :success
    end

    context 'GET: edit' do
      setup do
        page = FactoryBot.create :page
        get :edit, params: { id: page, page: { title: "EDITED page" } }
      end

      should respond_with :success
    end

    context 'POST :update' do
      setup do
        @page = FactoryBot.create :page
        post :update, params: { id: @page.id, page: { title: 'something else' } }
      end

      should redirect_to('the show page') { page_url(@page) }
    end

    context 'PUT :create' do
      setup do
        put :create, params: { page: { title: "New page created" } }
      end

      should redirect_to("the show page") { page_url(assigns(:page)) }
    end

    context 'DELETE :destroy' do
      setup do
        @page = FactoryBot.create :page
        delete :destroy, params: { id: @page }
      end

      should redirect_to("the pages page") { pages_url }
    end
  end

  context 'as a regular user' do
    context 'GET: index' do
      setup do
        get :index
      end

      should redirect_to("the sign in page") { new_user_session_url }
    end

    context 'GET :show' do
      setup do
        @page = FactoryBot.create(:page)
        get :show, params: { id: @page }
      end

      should respond_with :success
    end

    context 'PUT :create' do
      setup do
        put :create
      end

      should redirect_to("the sign in page") { new_user_session_url }
    end

    context 'POST :update' do
      setup do
        @page = FactoryBot.create :page
        post :update, params: { id: @page, title: 'something else' }
      end

      should redirect_to("the sign in page") { new_user_session_url }
    end
  end
end
