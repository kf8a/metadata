require File.expand_path('../../test_helper', __FILE__)

class DatatablesControllerTest < ActionController::TestCase
  def setup
    @table = FactoryBot.create(:datatable, dataset: FactoryBot.create(:dataset))

    FactoryBot.create(:datatable, dataset: FactoryBot.create(:dataset))

    # TODO: test with admin and non admin users
    signed_in_as_admin
  end

  def teardown
    # Website.destroy_all
  end

  context 'an unsigned in user' do
    context 'GET :index' do
      setup { get :index }

      should respond_with :success
    end

    context "GET :index / 'lter' subdomain" do
      setup { get :index, params: { requested_subdomain: 'lter' } }

      should render_with_layout :lter
    end

    context "GET :index / 'glbrc' subdomain" do
      setup { get :index, params: { requested_subdomain: 'glbrc' } }
    end

    # TODO: this test does not actually test anything because there are no results returned. Maybe
    # we need a mock here so we don't need to start thinking_sphinks.
    context 'GET :search' do
      setup { get :search, params: { keyword_list: 'test' } }
      should respond_with :success
    end

    context 'GET :show' do
      setup do
        @sponsor = FactoryBot.create :sponsor, name: 'glbrc', data_use_statement: 'smoke em if you got em'
        dataset = FactoryBot.create :dataset, sponsor: @sponsor
        datatable = FactoryBot.create :datatable, dataset: dataset

        get :show, params: { id: datatable }
      end

      should respond_with :success

      should 'include the link to the sponsors data use statement' do
        assert_select "a[href$=\/sponsors\\/#{@sponsor.id}]"
      end
    end

    context 'GET :show with version' do
      setup do
        @sponsor = FactoryBot.create :sponsor, data_use_statement: 'smoke em if you got em'
        dataset = FactoryBot.create :dataset, sponsor: @sponsor
        @datatable = FactoryBot.create :datatable, dataset: dataset

        get :show, params: { id: @datatable, version: 0 }
      end

      should respond_with :success
    end

    context 'GET :edit' do
      setup { get :edit, params: { id: @datatable } }
      should respond_with :redirect
      should redirect_to('the sign in page') { new_user_session_path }
    end

    context 'POST :update' do
      setup { post :update, params: { id: @datatable } }

      should respond_with :redirect
      should redirect_to('the sign in page') { new_user_session_path }
    end

    context 'GET /datatables/1.climdb' do
      setup do
        table = FactoryBot.create(:datatable, description: nil, dataset: FactoryBot.create(:dataset))
        get :show, params: { id: table, format: 'climdb' }
      end

      should 'give a real climdb document' do
        # TODO: This should really be parsed in some way
        assert_equal '!date', response.body.strip
      end
    end

    context "GET :show / 'glbrc' subdomain but lter datatable" do
      setup do
        lter_website = Website.find_by(name: 'lter')
        lter_website ||= FactoryBot.create(:website, name: 'lter')
        @lterdatatable = FactoryBot.create(:datatable, dataset: FactoryBot.create(:dataset, website: lter_website))
        get :show, params: { id: @lterdatatable, requested_subdomain: 'glbrc' }
      end

      should_not respond_with :success
    end

    context 'GET :qc' do
      setup { get :qc, params: { id: @table } }

      should respond_with :success
    end
  end

  context 'signed in as admin' do
    setup { signed_in_as_admin }

    # teardown { Website.destroy_all }

    context 'GET :index' do
      setup { get :index }

      should respond_with :success
    end

    context 'GET :new' do
      setup { get :new }

      should respond_with :success
    end

    context 'trying to create datatable with invalid parameters' do
      setup { post :create, params: { datatable: { title: 'something', abstract: 'something else' } } }

      should render_template 'new'
      should_not set_flash
    end

    context 'GET :show in the default domain' do
      setup do
        sponsor = FactoryBot.create :sponsor, name: 'lter'
        dataset = FactoryBot.create :dataset, sponsor: sponsor
        @datatable = FactoryBot.create :datatable, dataset: dataset, description: 'This is the first abstract'
        get :show, params: { id: @datatable }
      end

      should respond_with :success

      should 'include the abstract' do
        assert_select 'p', 'This is the first abstract'
      end

      #TODO figure out what fails here
      # context 'changing the description' do
      #   setup do
      #     put :update, :id => @datatable, :datatable => {:description => 'This is a new abstract'}
      #     get :show, :id => @datatable
      #   end

      #   should 'include the new abstract' do
      #     assert_select "p.description", "This is a new abstract"
      #   end

      # end
    end

    context 'GET :qc' do
      setup { get :qc, params: { id: @table } }

      should respond_with :success
    end
  end

  context 'GET :show in the subdomain' do
    setup do
      @datatable =
        FactoryBot.create(
          :datatable,
          dataset: FactoryBot.create(:dataset, sponsor: FactoryBot.create(:sponsor)),
          description: 'This is the first abstract'
        )
      get :show, params: { id: @datatable, requested_subdomain: 'glbrc' }
    end

    should 'include the abstract' do
      assert_select 'p', 'This is the first abstract'
    end

    # context 'changing the description' do
    #   setup do
    #     put :update, {:id => @datatable, :datatable => {:description => 'This is a new abstract'}}
    #     get :show, :id => @datatable, :requested_subdomain => 'glbrc'
    #   end

    #   should 'include the new abstract' do
    #     assert_select "p.description", "This is a new abstract"
    #   end

    # end
  end

  def test_should_show_datatable_in_csv_format
    get :show, params: { id: @table, format: 'csv' }
    assert_response :success
  end

  # #TODO renable after we get a common place to put these files S3 or gridfs
  # #  def test_should_create_csv_cache
  # #    file_cache = ActiveSupport::Cache.lookup_store(:file_store, 'tmp/cache')
  # #    assert_equal nil, file_cache.read("csv_#{@table.id}")
  # #    table_id = @table.id.to_s
  # #    get :show, :id => table_id, :format => "csv"
  # #    assert_equal @table.to_csv, file_cache.read("csv_#{@table.id}")
  # #  end

  def test_should_get_edit
    get :edit, params: { id: @table }
    assert_response :success
  end

  def test_should_update_datatable
    put :update, params: { id: @table, datatable: { title: 'soil moisture' } }
    assert_redirected_to datatable_path(assigns(:datatable))
  end

  context 'PUT :update with invalid attributes' do
    setup { put :update, params: { id: @table, datatable: { title: nil } } }

    should render_template 'edit'
    should_not set_flash
  end

  def test_should_destroy_datatable
    delete :destroy, params: { id: @table }

    assert_redirected_to datatables_path
  end

  context 'a datatable without description' do
    setup do
      @table =
        FactoryBot.create(
          :datatable,
          description: nil, dataset: FactoryBot.create(:dataset, sponsor: FactoryBot.create(:sponsor))
        )
      get :show, params: { id: @table }
    end

    should respond_with :success
    should render_template :show
  end

  context 'GET with empty search parameters' do
    setup { get :search, params: { keyword_list: '', commit: 'Search', requested_subdomain: 'lter' } }

    should redirect_to('datatables index') { datatables_url }
    should_not set_flash
  end

  context 'GET search with empty search parameters' do
    setup { get :search, params: { keyword_list: '' } }

    should redirect_to('datatables index') { datatables_url }
  end

  # Actual testing of the search function, with a real search, requires Sphinx I think. That seems like too much of a pain to have on always for the test suite. It will have to be tested manually.
end
