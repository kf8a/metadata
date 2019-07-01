# frozen_string_literal: true

require 'rails_helper'

describe CitationsController, type: :controller do
  render_views

  describe 'anonymous access' do
    before(:each) do
      Citation.delete_all # clear out other citations
      author1 = FactoryBot.create(:author, sur_name: 'Zebedee', seniority: 1)
      author2 = FactoryBot.create(:author, sur_name: 'Alfred',  seniority: 1)
      author3 = FactoryBot.create(:author, sur_name: 'Babbit',  seniority: 1)
      author4 = FactoryBot.create(:author, sur_name: 'Bob',     seniority: 1)
      website = Website.find_by(name: 'lter') || FactoryBot.create(:website, name: 'lter')
      @citation1 = FactoryBot.create(:article_citation, website: website,
                                                        authors: [author1],
                                                        title: 'citation1',
                                                        pub_year: 2010,
                                                        state: 'published')
      @citation2 = FactoryBot.create(:book_citation, website: website,
                                                     authors: [author2],
                                                     title: 'citation2',
                                                     pub_year: 2010,
                                                     state: 'published')
      @citation3 = FactoryBot.create(:chapter_citation, website: website,
                                                        authors: [author3],
                                                        title: 'citation3',
                                                        pub_year: 2010,
                                                        state: 'published')
      @citation4 = FactoryBot.create(:thesis_citation, website: website,
                                                       authors: [author4],
                                                       title: 'citation4',
                                                       pub_year: 2010,
                                                       state: 'published')

      @test = website
    end

    it 'GET index' do
      get :index

      expect(response.code).to eq '200'
      # expect(response).to render_with_layout('lter')
      expect(assigns(:citations).size).to eq 4
    end

    it 'returns citations alphabetical by last names' do
      get :index

      citations = assigns(:citations)
      expect(citations.first).to eq @citation2
      expect(citations.last).to eq @citation1
    end

    it 'returns citations in endnote format' do
      get :index, params: { format: :enw }

      expect(response).to have_http_status(:success)
    end

    it 'returns citations in bibtext format' do
      get :index, params: { format: :bib }

      expect(response).to have_http_status(:success)
    end

    it 'returns citations as rss feed' do
      get :index, params: { format: :rss }

      expect(response).to have_http_status(:success)
    end

    it 'returns citations based on the past dates' do
      get :index, params: { date: { year: (Time.zone.today.year - 1).to_s, month: '4', day: '16' } }
      expect(response).to have_http_status(:success)
      expect(assigns(:citations).size).to eq 4
    end

    it 'does not return citations before the date supplied' do
      get :index, params: { date: { year: (Time.zone.today.year + 1).to_s, month: '4', day: '16' } }
      expect(response).to have_http_status(:success)
      expect(assigns(:citations).size).to eq 0
    end

    it 'returns articles' do
      get :index, params: { type: 'article' }

      expect(response).to have_http_status(:success)
      citations = assigns(:citations)
      classes = citations.collect { |x| x.class.name }.sort.uniq.first
      expect(classes).to eq 'ArticleCitation'
    end

    it 'returns books' do
      get :index, params: { type: 'book' }

      expect(response).to have_http_status(:success)
      citations = assigns(:citations)
      classes = citations.collect { |x| x.class.name }.sort.uniq
      expect(classes).to include 'BookCitation'
      expect(classes).to include 'ChapterCitation'
      expect(classes).to_not include 'ArticleCitation'
    end

    it 'returns theses' do
      get :index, params: { type: 'thesis' }

      expect(response).to have_http_status(:success)
      citations = assigns(:citations)
      classes = citations.collect { |x| x.class.name }.sort.uniq
      expect(classes).to include 'ThesisCitation'
      expect(classes).to_not include 'ChapterCitation'
      expect(classes).to_not include 'ArticleCitation'
    end
  end

  it 'is uses the GLBRC layout if requested ' do
    get :index, params: { requested_subdomain: 'glbrc' }

    expect(response.code).to eq '200'
    expect(response).to render_with_layout('glbrc')
  end

  it 'redirects to sign in when downloading' do
    @citation = FactoryBot.create :citation
    get :download, params: { id: @citation }

    expect(response).to redirect_to '/sign_in'
  end

  it 'allows access to an open access publication' do
    @citation = FactoryBot.create :citation
    @citation.open_access = true

    get :download, params: { id: @citation }

    expect(response).to have_http_status(:redirect)
  end

  it 'redirects to sign in on GET: new' do
    get :new
    expect(response).to redirect_to '/users/sign_in'
  end

  it 'redirects to sign in on POST :create' do
    post :create
    expect(response).to redirect_to '/users/sign_in'
  end

  it 'redirects to sign in on GET :edit' do
    citation = FactoryBot.create :citation
    get :edit, params: { id: citation }
    expect(response).to redirect_to '/users/sign_in'
  end

  it 'redirects to sign in on PUT :update' do
    citation = FactoryBot.create :citation
    put :update, params: { id: citation, citation: { title: 'New title' } }
    expect(response).to redirect_to '/users/sign_in'
  end

  it 'redirects to sign in on DELETE' do
    citation = FactoryBot.create :citation
    delete :destroy, params: { id: citation }
    expect(response).to redirect_to '/users/sign_in'
  end

  describe 'filtering of citations' do
    before(:each) do
      @website = Website.find_or_create_by(name: 'lter')

      author1 = FactoryBot.create(:author, sur_name: 'Zebedee', seniority: 1)
      @citation1 = ArticleCitation.new
      @citation1.authors << Author.new(sur_name: 'Loecke',
                                       given_name: 'T', middle_name: 'D',
                                       seniority: 1)

      @citation1.authors << Author.new(sur_name: 'Robertson',
                                       given_name: 'G', middle_name: 'P',
                                       seniority: 2)

      @citation1.title = 'Soil resource heterogeneity in the form of aggregated'\
                         ' litter alters maize productivity'
      @citation1.publication = 'Plant and Soil'
      @citation1.volume = '325'
      @citation1.start_page_number = 231
      @citation1.ending_page_number = 241
      @citation1.pub_year = 2008
      @citation1.abstract = 'An abstract of the article.'
      @citation1.website = @website
      @citation1.save
      @citation1.publish!

      @another_citation = @website.citations.new
      @another_citation.authors << author1
      @another_citation.pub_year = 2007
      @another_citation.save
      @another_citation.publish!
    end

    describe 'GET :filtered, sort_by: id' do
      before(:each) do
        get :filtered, params: { requested_subdomain: 'lter', sort_by: 'id' }
      end

      it 'should order the citations by id' do
        expect(assigns(:website)).to eq @website
        correct_sorting = @website.citations.order('id').published
        expect(correct_sorting).to include @another_citation
        expect(assigns(:citations).all).to eq correct_sorting.all
      end
    end

    describe 'GET :filtered, sort_by: pub_year' do
      before(:each) do
        get :filtered, params: { requested_subdomain: 'lter', sort_by: 'pub_year' }
      end

      it 'should order the citations by pub_year' do
        correct_sorting = @website.citations.order('pub_year').published
        expect(correct_sorting).to include @another_citation
        expect(assigns(:citations).all).to eq correct_sorting.all
      end
    end

    describe 'GET :filtered, type: ArticleCitation' do
      before(:each) do
        get :filtered, params: { requested_subdomain: 'lter', type: 'ArticleCitation' }
      end

      it 'should only include article citations' do
        correct_list = @website.citations.by_type('ArticleCitation').published
        expect(correct_list).to include @citation1
        expect(correct_list).to_not include @another_citation
        my_list = correct_list.all
        expect(assigns(:citations).all).to eq my_list
      end
    end

    it 'includes submitted citations' do
      @citation1.state = 'submitted'
      assert @citation1.save
      get :index

      expect(response.code).to eq '200'
      expect(assigns(:submitted_citations)).to include(@citation1)
    end

    it 'includes forthcoming citations' do
      @citation1.state = 'forthcoming'
      assert @citation1.save
      get :index

      expect(response.code).to eq '200'
      expect(assigns(:forthcoming_citations)).to include(@citation1)
    end

    it 'includes published citations' do
      @citation1.state = 'published'
      assert @citation1.save
      get :index

      expect(response.code).to eq '200'
      expect(assigns(:citations)).to include(@citation1)
    end
  end

  describe 'authenticated ' do
    before(:each) do
      sign_in(FactoryBot.create(:admin_user))
    end

    it 'creates citations from json data' do
      title = 'my title'
      params = { citation: { title: title, author_block: 'Author Be' }, format: :json }
      post :create, params:  params

      expect(assigns(:citation).title).to eq title
      expect(response).to be_redirect
    end
  end
end
