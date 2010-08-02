require File.dirname(__FILE__) + '/../test_helper'
require 'datasets_controller'

# Re-raise errors caught by the controller.
class DatasetsController; def rescue_action(e) raise e end; end

class DatasetsControllerTest < ActionController::TestCase
  

  def setup
    @dataset = Factory.create(:dataset)
    Factory.create(:dataset)
    
    #TODO test with admin and non admin users
    @controller.current_user = User.new(:role => 'admin')
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
  
  context "POST :create with invalid parameters" do
    setup do
      post :create, :dataset => {:abstract => nil}
    end
    
    should render_template :new
    should_not set_the_flash
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
  
  context "PUT :update with invalid parameters" do
    setup do
      put :update, :id => @dataset, :dataset => {:abstract => nil}
    end
    
    should render_template :edit
    should_not set_the_flash
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
  
  context "eml harvester document is used as parameter for index" do
    setup do
      @dataset = Factory.create(:dataset)
      get :index, :Dataset => @dataset
    end
    
    should respond_with :success
    should respond_with_content_type :eml
  end
end
