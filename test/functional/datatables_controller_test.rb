require File.dirname(__FILE__) + '/../test_helper'
require 'datatables_controller'

# Re-raise errors caught by the controller.
class DatatablesController; def rescue_action(e) raise e end; end

class DatatablesControllerTest < ActionController::TestCase
  #fixtures :datatables

  def setup
    @table = Factory.create(:datatable, :dataset => Factory.create(:dataset))
    
    Factory.create(:datatable, :dataset => Factory.create(:dataset))
    Factory.create(:website, :id=>1).save
    
    #TODO test with admin and non admin users
    @controller.current_user = User.new(:role => 'admin')
  end
  
  def teardown
    @controller.expire_fragment(%r{.*})
    Website.destroy_all
    Template.destroy_all
  end

  def test_should_get_index
    get :index, :requested_subdomain => 'lter'
    assert_response :success
    assert assigns(:datatables)
  end
  
  test "should get the LTER version of the index" do
    get :index, :requested_subdomain => 'lter'
    assert_select 'h1', 'LTER Data Catalog'
  end
  
  test "should create index cache for lter" do
    get :index, :requested_subdomain => 'lter'
    assert @controller.fragment_exist?(:controller => "datatables", :action => "index", :action_suffix => "lter")
  end

  test "should get the glbrc version of the index" do
    get :index, :requested_subdomain => 'glbrc'
    assert_select 'h1', 'GLBRC Data Catalog'
  end  

  test "should create index cache for glbrc" do
    get :index, :requested_subdomain => 'glbrc'
    assert @controller.fragment_exist?(:controller => "datatables", :action => "index", :action_suffix => "glbrc")
  end
  
  test "index should get the template in the database if there is one" do
    lter_website = Factory.create(:website, :name => 'lter')
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
    assert assigns(:plate)
    assert_select 'h3#correct'
  end
  
  test "index should get the template in app/views if no db template" do
    lter_website = Website.find_by_name('lter')
    assert_nil lter_website
    assert !@controller.fragment_exist?(:controller => "datatables", :action => "index", :action_suffix => "lter")
    get :index, :requested_subdomain => 'lter'
    assert_select 'h3#correct', false
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_datatable
    old_count = Datatable.count
    post :create, :datatable => {:title => 'soil pH', :dataset_id => 1 }
    assert_equal old_count+1, Datatable.count
    
    assert_redirected_to datatable_path(assigns(:datatable))
  end

  def test_should_show_datatable
    get :show, :id => @table
    assert_response :success
  end
  
  def test_should_show_datatable_in_csv_format
    get :show, :id => @table, :format => "csv"
    assert_response :success
  end
  
  def test_should_create_csv_cache
    table_id = @table.id.to_s
    get :show, :id => table_id, :format => "csv"
    assert @controller.fragment_exist?(:controller => "datatables", :action => "show", :id => table_id, :format => "csv") 
  end
  
  test "show should get the template in the database if there is one" do
    lter_website = Factory.create(:website, :name => 'lter')
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
    assert assigns(:plate)
    assert_select 'h3#correct'
  end
  
  test "show should get the template in app/views if no db template" do
    lter_website = Website.find_by_name('lter')
    assert_nil lter_website
    assert !@controller.fragment_exist?(:controller => "datatables", :action => "show", :action_suffix => "lter")
    get :show, :id => @table, :requested_subdomain => 'lter'
    assert_select 'h3#correct', false
  end
  
  def test_should_get_edit
    get :edit, :id => @table
    assert_response :success
  end
  
  def test_should_delete_csv_cache
    table_id = @table.id.to_s
    get :show, :id => table_id, :format => "csv"
    assert @controller.fragment_exist?(:controller => "datatables", :action => "show", :id => table_id, :format => "csv")
    get :delete_csv_cache, :id => table_id
    assert !@controller.fragment_exist?(:controller => "datatables", :action => "show", :id => table_id, :format => "csv")
  end

  def test_should_update_datatable
    put :update, :id => @table, :datatable => {:title => 'soil moisture' }
    assert_redirected_to datatable_path(assigns(:datatable))
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
      get :index, :keyword_list => '', :commit => 'Search', :requested_subdomain => 'lter'
    end
  
    should assign_to :datatables
    should assign_to :themes
        
    should respond_with :success
    should render_template :index
    should_not set_the_flash
    
    
  end
  
  context 'GET /datatables/1.climdb' do
    setup do 
      table = Factory.create(:datatable, :description=>nil, :dataset => Factory.create(:dataset))
      get :show,  :id => table, :format => '.climdb'
    end
    
    
    
  end
  
end
