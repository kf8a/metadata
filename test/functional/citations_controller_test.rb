require File.expand_path('../../test_helper',__FILE__) 

class CitationsControllerTest < ActionController::TestCase

  context 'anonymous user' do
    setup do
      @controller.current_user = nil
    end

    context 'GET :index from anonymous user' do
      setup do
        Citation.delete_all  #clear out other citations
        author1 = Factory.create(:author, :sur_name => 'Zebedee', :seniority => 1)
        author2 = Factory.create(:author, :sur_name => 'Alfred',  :seniority => 1)
        @citation1 = Factory.create(:citation, 
          :authors => [author1], :title => 'citation1', :pub_year => 2010, :state => 'published')
        @citation2 = Factory.create(:citation, 
          :authors => [author2], :title => 'citation2', :pub_year => 2010, :state => 'published')
        get :index
      end

      should respond_with :success
      should assign_to :citations

      should render_with_layout 'lter'

      should 'return the citations in alphabetical order' do
#        citations = assigns(:citations)
        assert_equal 2, assigns(:citations).size
 
        assert_equal @citation2, citations[0]
        assert_equal @citation1,  citations[1] 
      end

      context 'in endnote format' do
        setup {get :index, :format=>:enw}
        should assign_to :citations
        should respond_with :success
      end

      context 'with a past date' do
        setup do 
          date = Date.today
          get :index, :date=>{:year=>"#{date.year - 1}", :month=>'4', :day => '16'}
        end
        should respond_with :success
        should assign_to :citations
        should 'not have any citations since the date is in the future' do
          assert_equal 2, assigns(:citations).size
        end
      end

      context 'with a future date parameter' do
        setup do 
          date = Date.today
          get :index, :date=>{:year=>"#{date.year + 1}", :month=>'4', :day => '16'}
        end
        should respond_with :success
        should assign_to :citations
        should 'not have any citations since the date is in the future' do
          assert_equal 0, assigns(:citations).size
        end
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

      should redirect_to('the sign in page') { sign_in_url }
    end

    context 'GET: download an open access publication' do
      setup do
        @citation= Factory :citation
        @citation.open_access = true

        get :download, :id => @citation
      end

      should respond_with :redirect
    end

    context 'GET :show' do
      setup do
        @citation = Factory :citation, :abstract => '*Something*', :title => 'article'
        get :show, :id => @citation
      end

      should respond_with :success

      context 'in endnote format' do
        setup {get :show, :id => @citation, :format=>'enw'}
        should respond_with :success

      end
    end

    # this form is to enter the date for the downloading citations older than the date.
    context 'get the download form' do
      setup {get :biblio}
      should respond_with :success
    end

    context 'GET: new' do
      setup do
        get :new
      end
      should respond_with :forbidden
    end

    context 'POST: create' do
      setup do
        post :create 
      end

      should respond_with :forbidden
    end

    context 'GET: edit' do
      setup do
        citation = Factory.create :citation
        post :edit, :id => citation
      end

      should respond_with :forbidden
    end

    context 'POST: update' do
      setup do
        @citation = Factory.create :citation
        post :update, :id => @citation, :title => 'nothing'
      end

      should respond_with :forbidden
    end

    context 'DELETE' do
      setup do 
        citation = Factory :citation
        post :destroy, :id => citation
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
    
    context 'GET: new' do
      setup do
        get :new
      end

      should respond_with :forbidden
    end

    context 'POST: create' do
      setup do
        post :create
      end

      should respond_with :forbidden
    end
    
    context 'GET: edit' do
      setup do
        @citation = Factory.create :citation
        get :edit, :id => @citation
      end

      should respond_with :forbidden
    end

    context 'POST: update' do
      setup do
        @citation = Factory.create :citation
        post :update, :id => @citation, :title=>'nothing'
      end

      should respond_with :forbidden
    end

    context 'DELETE' do
      setup do 
        citation = Factory :citation
        post :destroy, :id => citation
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

    context 'GET: edit' do
      setup do
        citation = Factory.create :citation
        citation.authors = [Factory.create(:author), Factory.create(:author)]
        citation.editors = [Factory.create(:editor), Factory.create(:editor)]
        get :edit, :id => citation
      end

      should respond_with :success
      should assign_to(:citation)

      should 'have an author' do
        assert_select '#citation_authors_attributes_0_given_name'
      end

      should 'have an editor' do
        assert_select '#citation_editors_attributes_0_given_name'
      end

    end

    context 'POST: update' do
      setup do
        citation = Factory.create :citation
        post :update, :id => citation, :citation => {:title => 'nothing' }
      end

      should respond_with :redirect
      should redirect_to('the citation page') {citation_url(assigns(:citation))}
      should assign_to(:citation)

      should 'actually save the title' do
        assert_equal 'nothing', assigns(:citation).title
      end
    end

    context 'DESTROY' do
      setup do
        @citation = Factory.create :citation
        post :destroy, :id => @citation
      end

      should redirect_to('the citation index page') {citations_url() }
    end
  end
end
