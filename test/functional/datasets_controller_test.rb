require File.dirname(__FILE__) + '/../test_helper'
require 'datasets_controller'

# Re-raise errors caught by the controller.
class DatasetsController; def rescue_action(e) raise e end; end

class DatasetsControllerTest < ActionController::TestCase
  

  def setup
    @controller = DatasetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @dataset = Factory.create(:dataset)
    Factory.create(:dataset)
  end
 
  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_dataset
    old_count = Dataset.count
    post :create, :dataset => {:abstract => 'some text' }
    assert_equal old_count+1, Dataset.count
    
    assert_redirected_to dataset_path(assigns(:dataset))
  end

  def test_should_show_dataset
    get :show, :id => @dataset
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => @dataset
    assert_response :success
  end
  
  def test_should_update_dataset
    put :update, :id => @dataset, :dataset => { }
    assert_redirected_to dataset_path(assigns(:dataset))
  end
  
  def test_should_destroy_dataset
    old_count = Dataset.count
    delete :destroy, :id => @dataset
    assert_equal old_count-1, Dataset.count
    
    assert_redirected_to datasets_path
  end
  
  context 'GET index' do
    setup do
      @dataset = Factory.create(:dataset)
      Factory.create(:dataset)
      
      get :index
    end
    
    should assign_to :datasets
    should assign_to :people
    should assign_to :themes
    
    should respond_with :success
    should render_template :index
    should_not set_the_flash
    
  end
  
  context 'GET with empty search parameters' do
    setup do
      get :index, :keyword_list => '', :commit => 'Search'
    end
  
    should assign_to :datasets
    should assign_to :people
    should assign_to :themes
    should assign_to :studies
        
    should respond_with :success
    should render_template :index
    should_not set_the_flash
  end
  
      
  context 'eml harvester document' do
    setup do
      @dataset = Factory.create(:dataset)
      get :index, :format => :eml
    end
    
    should 'be succesful'
  end
end
