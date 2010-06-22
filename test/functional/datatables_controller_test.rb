require File.dirname(__FILE__) + '/../test_helper'
require 'datatables_controller'

# Re-raise errors caught by the controller.
class DatatablesController; def rescue_action(e) raise e end; end

class DatatablesControllerTest < ActionController::TestCase
  #fixtures :datatables

  def setup
    @controller = DatatablesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @table = Factory.create(:datatable, :dataset => Factory.create(:dataset))
    
    Factory.create(:datatable, :dataset => Factory.create(:dataset))
    Factory.create(:website, :id=>1).save
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:datatables)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_datatable
    old_count = Datatable.count
    post :create, :datatable => {:title => 'soil pH' }
    assert_equal old_count+1, Datatable.count
    
    assert_redirected_to datatable_path(assigns(:datatable))
  end

  def test_should_show_datatable
    get :show, :id => @table
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => @table
    assert_response :success
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
      get :index,:keyword_list => '', :commit => 'Search'
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
