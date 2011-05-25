require File.expand_path('../../test_helper',__FILE__)

class CitationsControllerTest < ActionController::TestCase

  context 'anonymous user' do
    setup do
      @website = Website.find_or_create_by_name('lter')
      @controller.current_user = nil
    end

    context 'GET :index with an article citation' do
      setup do
        Citation.delete_all  #clear out other citations
        author1 = Factory.create(:author, :sur_name => 'Zebedee', :seniority => 1)
        author2 = Factory.create(:author, :sur_name => 'Alfred',  :seniority => 1)
        website = Website.find_by_name("lter") || Factory.create(:website, :name => "lter")
        @citation1 = ArticleCitation.new
        @citation1.authors << Author.new( :sur_name => 'Loecke',
                                       :given_name => 'T', :middle_name => 'D',
                                       :seniority => 1)

        @citation1.authors << Author.new(:sur_name => 'Robertson',
                                      :given_name => 'G', :middle_name => 'P',
                                      :seniority => 2)

        @citation1.title = 'Soil resource heterogeneity in the form of aggregated litter alters maize productivity'
        @citation1.publication = 'Plant and Soil'
        @citation1.volume = '325'
        @citation1.start_page_number = 231
        @citation1.ending_page_number = 241
        @citation1.pub_year = 2008
        @citation1.abstract = 'An abstract of the article.'
        @citation1.website = website
      end

      context 'submitted' do
        setup do
          @citation1.state = 'submitted'
          assert @citation1.save
          get :index
        end
        should respond_with(:success)
        should "include the submitted article citation" do
          assert assigns(:submitted_citations).include?(@citation1)
       end
      end

      context 'forthcomming' do
        setup do
          @citation1.state = 'forthcoming'
          assert @citation1.save
          get :index
        end
        should respond_with(:success)
        should "include the forthcoming article citation" do
          assert assigns(:forthcoming_citations).include?(@citation1)
       end
      end

      context 'published' do
        setup do
          @citation1.state = 'published'
          assert @citation1.save
          get :index
        end
        should respond_with(:success)
        should "include the published article citation" do
          assert assigns(:citations).include?(@citation1)
       end

      end
    end

    context 'GET :index from anonymous user' do
      setup do
        Citation.delete_all  #clear out other citations
        author1 = Factory.create(:author, :sur_name => 'Zebedee', :seniority => 1)
        author2 = Factory.create(:author, :sur_name => 'Alfred',  :seniority => 1)
        website = Website.find_by_name("lter") || Factory.create(:website, :name => "lter")
        @citation1 = Factory.create(:citation, :website => website,
          :authors => [author1], :title => 'citation1', :pub_year => 2010, :state => 'published')
        @citation2 = Factory.create(:citation, :website => website,
          :authors => [author2], :title => 'citation2', :pub_year => 2010, :state => 'published')
        get :index
      end

      should respond_with :success
      should assign_to :citations

      should render_with_layout 'lter'

      should 'return the citations in order of author last name' do
        citations = assigns(:citations)
        assert_equal 2, citations.size
        assert_equal @citation2, citations[0]
        assert_equal @citation1,  citations[1]
      end

      context 'in endnote format' do
        setup {get :index, :format=>:enw}
        should assign_to :citations
        should respond_with :success
      end

      context 'as an rss feed' do
        setup {get :index, :format => :rss}
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

      context 'in bibtext format' do
        setup {get :show, :id=>@citation, :format => 'bib'}
        should respond_with :success
        should assign_to :citation
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

      should redirect_to('the sign in path') { sign_in_path }
    end

    context 'POST: create' do
      setup do
        post :create
      end

      should redirect_to('the sign in path') { sign_in_path }
    end

    context 'GET: edit' do
      setup do
        citation = Factory.create :citation
        post :edit, :id => citation
      end

      should redirect_to('the sign in path') { sign_in_path }
    end

    context 'POST: update' do
      setup do
        @citation = Factory.create :citation
        post :update, :id => @citation, :title => 'nothing'
      end

      should redirect_to('the sign in path') { sign_in_path }
    end

    context 'DELETE' do
      setup do
        citation = Factory :citation
        post :destroy, :id => citation
      end

      should redirect_to('the sign in path') { sign_in_path }
    end

  end


  context 'signed in user' do

    setup do
      @website = Website.find_or_create_by_name('lter')
      signed_in_as_normal_user
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

      should redirect_to('the sign in path') { sign_in_path }
    end

    context 'POST: create' do
      setup do
        post :create
      end

      should redirect_to('the sign in path') { sign_in_path }
    end

    context 'GET: edit' do
      setup do
        @citation = Factory.create :citation
        get :edit, :id => @citation
      end

      should redirect_to('the sign in path') { sign_in_path }
    end

    context 'POST: update' do
      setup do
        @citation = Factory.create :citation
        post :update, :id => @citation, :title=>'nothing'
      end

      should redirect_to('the sign in path') { sign_in_path }
    end

    context 'DELETE' do
      setup do
        citation = Factory :citation
        post :destroy, :id => citation
      end

      should redirect_to('the sign in path') { sign_in_path }
    end
  end

  context 'signed in as admin' do

    setup do
      @website = Website.find_or_create_by_name('lter')
      signed_in_as_admin
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

      should 'create a citation for the website currently using' do
        assert_equal @website, Citation.find(assigns(:citation)).website
      end

      should redirect_to('the citation page') { citation_url(assigns(:citation)) }
    end

    context 'POST: create with attachment' do
      setup do
        post :create, :citation => {:pdf => 'testing'}
      end

      should redirect_to('the citation page') {citation_url(assigns(:citation))}

    end

    context 'POST: create with type' do
      setup do
        post :create, :citation => {:type => 'ArticleCitation'}
      end

      should assign_to(:citation)
      should redirect_to('the citation show page') {citation_url(assigns(:citation))}

      should 'have a type of ArticleCitation' do
        assert_equal 'ArticleCitation', assigns(:citation).type
      end

      should 'be an article' do
        assert_kind_of ArticleCitation, Citation.find(assigns(:citation).id)
      end
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

      should 'have an editor' do
        assert_select '#citation_editors_attributes_0_given_name'
      end

    end

    context 'POST: update' do
      setup do
        citation = Factory.create :citation
        post :update, :id => citation.id, :citation => {:title => 'nothing', :type=>'ArticleCitation' }
      end

      should redirect_to('the citation page') {citation_url(assigns(:citation))}
      should assign_to(:citation)

      should 'assign a type of ArticleCitation' do
        assert_equal 'ArticleCitation', assigns(:citation).type
      end

      should 'actually save the title' do
        assert_equal 'nothing', assigns(:citation).title
      end

      should 'set the type to article' do
        assert_kind_of ArticleCitation, Citation.find(assigns(:citation).id)
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

  def test_caching_and_expiring
    @citation = Factory.create :citation
    get :show, :id => @citation
    assert @controller.fragment_exist?(:controller => "citations", :action => "show", :id => @citation)
    put :update, :id => @citation, :citation => { :title => 'nothing' }
    assert !@controller.fragment_exist?(:controller => "citations", :action => "show", :id => @citation)
  end
end
