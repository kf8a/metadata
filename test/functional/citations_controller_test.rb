require File.dirname(__FILE__) + '/../test_helper'

class CitationsControllerTest < ActionController::TestCase

  context 'anonymous user' do
    setup do
      @controller.current_user = nil
    end

    context 'GET :index from anonymous user' do
      setup do
        Citation.delete_all  #clear out other citations
        author1 = Factory.create(:author, :sur_name => 'Zebedee', :seniority => 1)
        author2 = Factory.create(:author, :sur_name => 'Alfred', :seniority => 1)
        @citation1 = Factory.create(:citation, 
          :authors => [author1], :title => 'citation1', :pub_year => 2010)
        @citation2 = Factory.create(:citation, 
          :authors => [author2], :title => 'citation2', :pub_year => 2010)
        get :index
      end

      should respond_with :success
      should assign_to :citations

      should render_with_layout 'lter'
      
      should 'return the citations in alphabetical order' do
        citations = assigns(:citations)
        assert citations.size == 2
 
        assert citations[0] == @citation2
        assert citations[1] == @citation1
      end
      
    end
    
    context 'GET :index from glbrc' do
      setup do
        get :index, :requested_subdomain => 'glbrc'
      end
      
      should respond_with :success
      should assign_to :citations
      
      should render_with_layout 'glbrc'
      
    end
    
    context 'GET :download' do
      setup do
        @citation = Factory :citation
        get :download, :id => @citation
      end
      
      should redirect_to('the sign in page') { sign_up_url }
    end

    context 'POST: create' do
      setup do
        post :create 
      end

      should respond_with :forbidden
    end

  end

  context 'signed in user' do

    setup do
      @controller.current_user = Factory :user
    end

    context 'GET :index' do
      setup do
        get :index
      end

      should respond_with :success
      should assign_to :citations
    end

    context 'POST: create' do
      setup do
        post :create
      end

      should respond_with :forbidden
    end

  end

  context 'signed in as admin' do

    setup do
      @controller.current_user = Factory.create :admin_user
    end

    context 'GET :index' do
      setup do
        get :index
      end

      should respond_with :success
      should assign_to :citations

      should 'have a PDF download link'
    end

    context 'POST: create' do
      setup do
        post :create
      end

      should respond_with :redirect
      should redirect_to('the citation page') { citation_url(assigns(:citation)) }
    end

    context 'POST: create with attachment' do
      setup do
        post :create, :pdf => 'testing'
      end

      should respond_with :redirect
      should redirect_to('the citation page') {citation_url(assigns(:citation))}

    end

  end
end
