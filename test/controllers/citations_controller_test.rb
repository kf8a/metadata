# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class CitationsControllerTest < ActionController::TestCase

  context 'signed in as an normal user' do
    setup do
      @website = Website.where(name: 'lter').first_or_create
      signed_in_as_normal_user
    end

    context 'GET :index' do
      setup do
        get :index
      end

      should respond_with :success
    end

    context 'GET: new' do
      setup do
        get :new
      end

      should redirect_to('/') { root_path }
    end

    context 'POST: create' do
      setup do
        post :create
      end

      should redirect_to('/') { root_path }
    end

    context 'GET: edit' do
      setup do
        @citation = FactoryBot.create :citation
        get :edit, params: { id: @citation }
      end

      should redirect_to('/') { root_path }
    end

    context 'POST: update' do
      setup do
        @citation = FactoryBot.create :citation
        post :update, params: { id: @citation, title: 'nothing' }
      end

      should redirect_to('/') { root_path }
    end

    context 'DELETE' do
      setup do
        citation = FactoryBot.create :citation
        post :destroy, params: { id: citation }
      end

      should redirect_to('/') { root_path }
    end
  end

  context 'signed in as admin' do
    setup do
      @website = Website.where(name: 'lter').first_or_create
      signed_in_as_admin
    end

    context 'GET :index' do
      setup do
        get :index
      end

      should respond_with :success
    end

    context 'POST: create' do
      setup do
        post :create, params: { citation: { author_block: 'Jim Jones' } }
      end

      should 'create a citation for the website currently using' do
        assert_equal @website, assigns(:citation).website
      end

      should redirect_to('the citation page') { citation_url(assigns(:citation)) }
    end

    context 'POST: create with type' do
      setup do
        post :create, params: { citation: { type: 'ArticleCitation', author_block: 'Jim Jones' } }
      end

      should redirect_to('the citation show page') { citation_url(assigns(:citation)) }

      should 'have a type of ArticleCitation' do
        assert_equal 'ArticleCitation', assigns(:citation).type
      end
    end

    context 'GET: edit' do
      setup do
        citation = FactoryBot.create :citation
        citation.authors = [FactoryBot.create(:author), FactoryBot.create(:author)]
        citation.editors = [FactoryBot.create(:editor), FactoryBot.create(:editor)]
        get :edit, params: { id: citation }
      end

      should respond_with :success
    end

    context 'POST: update' do
      setup do
        citation = FactoryBot.create :citation
        post :update, params: { id: citation.id,
                                citation: { title: 'nothing',
                                            type: 'ArticleCitation' } }
      end

      should redirect_to('the citation show page') {citation_url(assigns(:citation))}

      should 'assign a type of ArticleCitation' do
        assert_equal 'ArticleCitation', assigns(:citation).type
      end

      should 'actually save the title' do
        assert_equal 'nothing', assigns(:citation).title
      end
    end

    context 'DESTROY' do
      setup do
        @citation = FactoryBot.create :citation
        post :destroy, params: { id: @citation }
      end

      should redirect_to('the citation index page') {citations_url() }
    end
  end
end
