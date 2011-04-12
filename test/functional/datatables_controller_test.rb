require File.expand_path('../../test_helper',__FILE__)

class DatatablesControllerTest < ActionController::TestCase

  def setup
    @table = Factory.create(:datatable, :dataset => Factory.create(:dataset))

    Factory.create(:datatable, :dataset => Factory.create(:dataset))

    #TODO test with admin and non admin users
    signed_in_as_admin
  end

  def teardown
    @controller.expire_fragment(:controller => "datatables", :action => "index", :action_suffix => "lter")
    Website.destroy_all
    Template.destroy_all
  end

  context 'an unsigned in user' do
    setup do
      @controller.current_user = nil
    end

    context "GET :index" do
      setup do
        get :index
      end

      should respond_with :success
    end

    context "GET :index / 'lter' subdomain" do
      setup do
        get :index, :requested_subdomain => 'lter'
      end

      should render_template 'lter_index'
      should "create index cache" do
        assert @controller.fragment_exist?(:controller => "datatables", :action => "index", :action_suffix => "lter")
      end
    end

    context "GET :index / 'glbrc' subdomain" do
      setup do
        get :index, :requested_subdomain => 'glbrc'
      end

      should render_template 'glbrc_index'
      should "create index cache" do
        assert @controller.fragment_exist?(:controller => "datatables", :action => "index", :action_suffix => "glbrc")
      end
    end

    context 'GET :events' do
      setup do
        @sponsor  = Factory.create :sponsor, :data_use_statement => 'smoke em if you got em'
        dataset   = Factory.create :dataset, :sponsor => @sponsor
        datatable = Factory.create :datatable, :dataset => dataset
        get :events, :id => datatable, :format => :json
      end

      should respond_with :success
    end

    context 'GET :search' do
      setup do
        get :search, :keyword_list=>'test'
      end
      should respond_with :success
    end

    context 'GET :show' do
      setup do
        @sponsor  = Factory.create :sponsor, :data_use_statement => 'smoke em if you got em'
        dataset   = Factory.create :dataset, :sponsor => @sponsor
        datatable = Factory.create :datatable, :dataset => dataset

        get :show, :id => datatable
      end

      should respond_with :success

      should 'include the link to the sponsors data use statement' do
        assert_select "a[href$=/sponsors/#{@sponsor.id}]"
      end
    end

    context 'GET :show with version' do
      setup do
        @sponsor  = Factory.create :sponsor, :data_use_statement => 'smoke em if you got em'
        dataset   = Factory.create :dataset, :sponsor => @sponsor
        datatable = Factory.create :datatable, :dataset => dataset
        
        get :show, :id => datatable, :version => 0
      end

      should respond_with :success
    end
    
    context 'GET :edit' do
      setup do
        get :edit, :id => @table
      end
      should respond_with :redirect
      should redirect_to("the sign in page") {sign_in_path}
    end

    context 'POST :update' do
      setup do
        post :update, :id => @table
      end

      should respond_with :redirect
      should redirect_to("the sign in page") {sign_in_path}
    end

    context 'GET /datatables/1.climdb' do
      setup do
        table = Factory.create(:datatable, :description=>nil,
                                :dataset => Factory.create(:dataset))
        get :show,  :id => table, :format => 'climdb'
      end

      should respond_with_content_type(:csv)
      should 'give a real climdb document' do
        assert_equal "!\n\n", response.body
      end
    end

    context "show in climdb a restricted datatable on an untrusted ip" do
      setup do
        @restricted_datatable = Factory.create(:datatable,
                                                :is_restricted => true)
        @request[:remote_ip] = '142.222.1.2'
        get :show, :id => @restricted_datatable, :format => "climdb"
      end

      should redirect_to("the html version of the show page") {datatable_path(@restricted_datatable)}
    end

    context "GET :show / 'glbrc' subdomain but lter datatable" do
      setup do
        lter_website = Website.find_by_name('lter')
        lter_website = Factory.create(:website, :name => 'lter') unless lter_website
        @lterdatatable = Factory.create(:datatable, :dataset => Factory.create(:dataset, :website => lter_website))
        get :show, :id => @lterdatatable, :requested_subdomain => 'glbrc'
      end

      should_not respond_with :success
    end

    context "GET :qc" do
      setup do
        refute @table.can_be_quality_controlled_by?(@controller.current_user)
        get :qc, :id => @table
      end

      should respond_with :redirect
      should redirect_to("the sign in page") {sign_in_path}
    end

  end

  context 'signed in as admin' do
    setup do
      signed_in_as_admin
    end

    teardown do
      Website.destroy_all
      Template.destroy_all
    end

    context 'GET :index' do
      setup do
        get :index
      end

      should respond_with :success
    end

    context 'GET :new' do
      setup do
        get :new
      end

      should respond_with :success
    end

    context "trying to create datatable with invalid parameters" do
      setup do
        post :create, :datatable => {:title => nil}
      end

      should render_template "new"
      should_not set_the_flash
    end

    context 'GET :show in the default domain' do
      setup do
        @datatable = Factory.create :datatable, :dataset => Factory.create(:dataset),
                                    :description => 'This is the first abstract'
        get :show, :id => @datatable
      end

      should respond_with :success

      should 'include the abstract' do
        assert_select "p", "This is the first abstract"
      end

      should "create show cache" do
        assert @controller.fragment_exist?(:controller => "datatables", :action => "show", :action_suffix => 'page', :id => @datatable)
      end

      context 'changing the description' do
        setup do
          put :update, :id => @datatable, :datatable => {:description => 'This is a new abstract'}
          get :show, :id => @datatable
        end

        should 'include the new abstract' do
          assert_select "p.description", "This is a new abstract"
        end

      end
    end

    context "GET :qc" do
      setup do
        get :qc, :id => @table
      end

      should respond_with :success
    end

  end

  context 'GET :show in the subdomain' do
    setup do
      @datatable = Factory.create :datatable, :dataset => Factory.create(:dataset),
                                  :description => 'This is the first abstract'
      get :show, :id => @datatable, :requested_subdomain => 'glbrc'
    end

    should 'include the abstract' do
      assert_select "p", "This is the first abstract"
    end

    context 'changing the description' do
      setup do
        put :update, :id => @datatable, :datatable => {:description => 'This is a new abstract'}
        get :show, :id => @datatable, :requested_subdomain => 'glbrc'
      end

      should 'include the new abstract' do
        assert_select "p.description", "This is a new abstract"
      end

    end
  end

  test "index should get the template in the database if there is one" do
    lter_website = Website.find_by_name('lter')
    index_layout = Factory.create(:template,
                    :website_id => lter_website.id,
                    :controller => 'datatables',
                    :action     => 'index',
                    :layout     => '<h3 id="correct">LTER test index page</h3>')
    assert lter_website
    assert index_layout
    assert lter_website.layout('datatables', 'index')
    assert Website.find_by_name('lter')
    assert Website.find_by_name('lter').layout('datatables', 'index')
    get :index, :requested_subdomain => 'lter'
    assert_select 'h3#correct'
  end

  test "index should get the template in app/views if no db template" do
    lter_website = Website.find_by_name('lter')
    lter_website.destroy
    assert_nil Website.find_by_name('lter')
    assert !@controller.fragment_exist?(:controller => "datatables", :action => "index", :action_suffix => "lter")
    get :index, :requested_subdomain => 'lter'
    assert_select 'h3#correct', false
  end

  def test_should_create_datatable
    old_count = Datatable.count
    post :create, :datatable => {:title => 'soil pH', :dataset_id => 1 }
    assert_equal old_count+1, Datatable.count

    assert_redirected_to datatable_path(assigns(:datatable))
  end

  def test_should_show_datatable_in_csv_format
    get :show, :id => @table, :format => "csv"
    assert_response :success
  end


  #TODO renable after we get a common place to put these files S3 or gridfs
#  def test_should_create_csv_cache
#    file_cache = ActiveSupport::Cache.lookup_store(:file_store, 'tmp/cache')
#    assert_equal nil, file_cache.read("csv_#{@table.id}")
#    table_id = @table.id.to_s
#    get :show, :id => table_id, :format => "csv"
#    assert_equal @table.to_csv, file_cache.read("csv_#{@table.id}")
#  end

  test "show should get the template in the database if there is one" do
    lter_website = Website.find_by_name('lter')
    index_layout = Factory.create(:template,
                    :website_id => lter_website.id,
                    :controller => 'datatables',
                    :action     => 'show',
                    :layout     => '<h3 id="correct">LTER test show page</h3>')
    assert lter_website
    assert index_layout
    assert lter_website.layout('datatables', 'show')
    assert Website.find_by_name('lter')
    assert Website.find_by_name('lter').layout('datatables', 'show')
    get :show, :id => @table, :requested_subdomain => 'lter'
    assert_select 'h3#correct'
  end

  test "show should get the template in app/views if no db template" do
    lter_website = Website.find_by_name('lter')
    lter_website.destroy
    assert_nil Website.find_by_name('lter')
    assert !@controller.fragment_exist?(:controller => "datatables", :action => "show", :action_suffix => "lter", :id => @table)
    get :show, :id => @table, :requested_subdomain => 'lter'
    assert_select 'h3#correct', false
  end

  def test_should_get_edit
    get :edit, :id => @table
    assert_response :success
  end

  #TODO renable after we get the csv caches in a common place
#  def test_should_delete_csv_cache_on_update_table
#    file_cache = ActiveSupport::Cache.lookup_store(:file_store, 'tmp/cache')
#    table_id = @table.id.to_s
#    get :show, :id => table_id, :format => "csv"
#    assert_equal @table.to_csv, file_cache.read("csv_#{@table.id}")
#    put :update, :id => table_id, :datatable => { :description => "No CSV cache" }
#    assert_equal nil, file_cache.read("csv_#{@table.id}")
#  end

  def test_should_update_datatable
    put :update, :id => @table, :datatable => {:title => 'soil moisture' }
    assert_redirected_to datatable_path(assigns(:datatable))
  end

  context "PUT :update with invalid attributes" do
    setup do
      put :update, :id => @table, :datatable => {:title => nil}
    end

    should render_template "edit"
    should_not set_the_flash
  end

  def test_should_destroy_datatable
    old_count = Datatable.count
    delete :destroy, :id => @table
    assert_equal old_count-1, Datatable.count

    assert_redirected_to datatables_path
  end

  context 'a datatable without description' do
    setup do
      @table = Factory.create(:datatable, :description=>nil, :dataset => Factory.create(:dataset))
      get :show,  :id => @table
    end

    should respond_with :success
    should render_template :show
  end

  context 'GET with empty search parameters' do
    setup do
      get :search, :keyword_list => '', :commit => 'Search', :requested_subdomain => 'lter'
    end

    should redirect_to("datatables index") {datatables_url}
    should_not set_the_flash
  end

  context "GET search with empty search parameters" do
    setup do
      get :search, :keyword_list => ''
    end

    should redirect_to("datatables index") {datatables_url}
  end

  def test_caching_and_expiring
    @datatable = Factory.create :datatable, :dataset => Factory.create(:dataset),
                                  :description => 'This is the first abstract'
    get :show, :id => @datatable
    assert @datatable.is_sql
    assert @datatable.values
    assert @controller.fragment_exist?(:controller => "datatables", :action => "show", :action_suffix => 'page', :id => @datatable)
    assert @controller.fragment_exist?(:controller => "datatables", :action => "show", :action_suffix => 'data', :id => @datatable)
    put :update, :id => @datatable, :datatable => { }
    assert !@controller.fragment_exist?(:controller => "datatables", :action => "show", :action_suffix => 'page', :id => @datatable)
    assert !@controller.fragment_exist?(:controller => "datatables", :action => "show", :action_suffix => 'data', :id => @datatable)
  end

  def test_expiring_in_one_day
    @datatable = Factory.create :datatable, :dataset => Factory.create(:dataset),
                                  :description => 'This is the first abstract'
    get :show, :id => @datatable
    assert @datatable.is_sql
    assert @datatable.values
    assert @controller.fragment_exist?(:controller => "datatables", :action => "show", :action_suffix => 'data', :id => @datatable)
    future_time = Time.now + 1.day
    Time.stubs(:now).returns(future_time)
    assert !@controller.fragment_exist?(:controller => "datatables", :action => "show", :action_suffix => 'data', :id => @datatable)
    Time.unstub(:now) #otherwise all future tests think it's tomorrow
  end

  #Actual testing of the search function, with a real search, requires Sphinx I think. That seems like too much of a pain to have on always for the test suite. It will have to be tested manually.

end
