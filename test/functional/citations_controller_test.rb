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
        author1 = FactoryGirl.create(:author, :sur_name => 'Zebedee', :seniority => 1)
        author2 = FactoryGirl.create(:author, :sur_name => 'Alfred',  :seniority => 1)
        website = Website.find_by_name("lter") || FactoryGirl.create(:website, :name => "lter")
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

      context 'forthcoming' do
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
        author1 = FactoryGirl.create(:author, :sur_name => 'Zebedee', :seniority => 1)
        author2 = FactoryGirl.create(:author, :sur_name => 'Alfred',  :seniority => 1)
        author3 = FactoryGirl.create(:author, :sur_name => 'Babbit',  :seniority => 1)
        author4 = FactoryGirl.create(:author, :sur_name => 'Bob',     :seniority => 1)
        website = Website.find_by_name("lter") || FactoryGirl.create(:website, :name => "lter")
        @citation1 = FactoryGirl.create(:article_citation, :website => website,
                                        :authors => [author1], :title => 'citation1', :pub_year => 2010, 
                                        :state => 'published')
        @citation2 = FactoryGirl.create(:book_citation, :website => website,
                                        :authors => [author2], :title => 'citation2', :pub_year => 2010, 
                                        :state => 'published')
        @citation3 = FactoryGirl.create(:chapter_citation, :website => website,
                                        :authors => [author3], :title => 'citation3', :pub_year => 2010,
                                        :state => 'published' )
        @citation4 = FactoryGirl.create(:thesis_citation, :website => website,
                                        :authors => [author4], :title => 'citation4', :pub_year => 2010,
                                        :state => 'published' )

        @test = website
        get :index
      end

      should respond_with :success

      should render_with_layout 'lter'

      should 'return 4 citations' do
        citations = assigns(:citations)
        assert_equal 4, citations.size
      end

      should 'return the citations in order of author last name' do
        citations = assigns(:citations)
        assert_equal @citation2, citations.first
        assert_equal @citation1,  citations.last
      end

      context 'in endnote format' do
        setup {get :index, :format=>:enw}
        should respond_with :success
      end

      context 'as an rss feed' do
        setup {get :index, :format => :rss}
        should respond_with :success
      end

      context 'with a past date' do
        setup do
          date = Date.today
          get :index, :date=>{:year=>"#{date.year - 1}", :month=>'4', :day => '16'}
        end
        should respond_with :success
        should 'have all citations since the date is in the past' do
          assert_equal 4, assigns(:citations).size
        end
      end

      context 'with a future date parameter' do
        setup do
          date = Date.today
          get :index, :date=>{:year=>"#{date.year + 1}", :month=>'4', :day => '16'}
        end
        should respond_with :success
        should 'not have any citations since the date is in the future' do
          assert_equal 0, assigns(:citations).size
        end
      end

      context 'with type article' do
        setup do
          get :index , :type => 'article'
        end

        should respond_with :success

        should 'only include article citations' do
          citations = assigns(:citations)
          assert_equal 'ArticleCitation',  citations.collect {|x| x.class.name}.sort.uniq.first
        end
      end

      context 'with type book' do
        setup do
          get :index, :type => 'book'
        end

        should respond_with :success

        should 'only include book citations' do
          citations = assigns(:citations)
          class_names = citations.collect {|x| x.class.name}
          assert_includes class_names, 'BookCitation' 
          assert_includes class_names, 'ChapterCitation'
          refute_includes class_names, 'ArticleCitation'
        end
      end

      context 'with type thesis' do
        setup { get :index, :type => 'thesis' }

        should respond_with :success

        should 'only include thesis citaitons' do
          citations = assigns(:citations)
          class_names = citations.collect {|x| x.class.name}
          assert_includes class_names, 'ThesisCitation' 
          refute_includes class_names, 'ChapterCitation'
          refute_includes class_names, 'ArticleCitation'
        end
      end
    end


    context 'GET :index from glbrc' do
      setup do
        get :index, :requested_subdomain => 'glbrc'
      end

      should respond_with :success

      should render_with_layout 'glbrc'

    end

    context 'GET :download' do
      setup do
        @citation = FactoryGirl.create :citation
        get :download, :id => @citation
      end

      should redirect_to('the sign in page') { sign_in_url }
    end

    context 'GET: download an open access publication' do
      setup do
        @citation= FactoryGirl.create :citation
        @citation.open_access = true

        get :download, :id => @citation
      end

      should respond_with :redirect
    end

    context 'GET :show' do
      setup do
        @citation = FactoryGirl.create :citation, :abstract => '*Something*', :title => 'article'
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
        citation = FactoryGirl.create :citation
        post :edit, :id => citation
      end

      should redirect_to('the sign in path') { sign_in_path }
    end

    context 'POST: update' do
      setup do
        @citation = FactoryGirl.create :citation
        post :update, :id => @citation, :title => 'nothing'
      end

      should redirect_to('the sign in path') { sign_in_path }

    end

    context 'DELETE' do
      setup do
        citation = FactoryGirl.create :citation
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
        @citation = FactoryGirl.create :citation
        get :edit, :id => @citation
      end

      should redirect_to('/') { root_path }
    end

    context 'POST: update' do
      setup do
        @citation = FactoryGirl.create :citation
        post :update, :id => @citation, :title=>'nothing'
      end

      should redirect_to('/') { root_path }
    end

    context 'DELETE' do
      setup do
        citation = FactoryGirl.create :citation
        post :destroy, :id => citation
      end

      should redirect_to('/') { root_path }
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

    end

    context 'POST: create' do
      setup do
        post :create,:citation => {:author_block => 'Jim Jones'}
      end

      should 'create a citation for the website currently using' do
        assert_equal @website, Citation.find(assigns(:citation)).website
      end

      should redirect_to('the citation page') { citation_url(assigns(:citation)) }
    end

    context 'POST: create with type' do
      setup do
        post :create, :citation => {:type => 'ArticleCitation', :author_block => 'Jim Jones'}
      end

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
        citation = FactoryGirl.create :citation
        citation.authors = [FactoryGirl.create(:author), FactoryGirl.create(:author)]
        citation.editors = [FactoryGirl.create(:editor), FactoryGirl.create(:editor)]
        get :edit, :id => citation
      end

      should respond_with :success
    end

    context 'POST: update' do
      setup do
        citation = FactoryGirl.create :citation
        post :update, :id => citation.id, :citation => {:title => 'nothing', 
                                                        :type=>'ArticleCitation' }
      end

      should respond_with :success

      should 'assign a type of ArticleCitation' do
        assert_equal 'ArticleCitation', assigns(:citation).type
      end

      should 'actually save the title' do
        assert_equal 'nothing', assigns(:citation).title
      end
    end

    context 'DESTROY' do
      setup do
        @citation = FactoryGirl.create :citation
        post :destroy, :id => @citation
      end

      should redirect_to('the citation index page') {citations_url() }
    end

    should 'test_caching_and_expiring_for_update' do
      Rails.cache.clear
      @citation = FactoryGirl.create :citation
      get :index
      assert @controller.fragment_exist?(:action => "index", :action_suffix=>'-')
      put :update, :id => @citation, :citation => { :title => 'nothing' }
      assert_equal @citation, assigns(:citation)
      assert Citation.find_by_title('nothing')
      assert !@controller.fragment_exist?(:controller => "citations", :action => "index")
    end

    should 'test_caching_and_expiring_for_create' do
      Rails.cache.clear
      get :index
      assert @controller.fragment_exist?(:controller => "citations", :action => "index", :action_suffix => '')
      post :create, :citation => { :title => 'a brand new citation' }
      assert Citation.find_by_title('a brand new citation')
      assert !@controller.fragment_exist?(:controller => "citations", :action => "index")
    end

  end
end
