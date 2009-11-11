require File.dirname(__FILE__) + '/../test_helper'
require 'datasets_controller'

# Re-raise errors caught by the controller.
class DatasetsController; def rescue_action(e) raise e end; end

class DatasetsControllerTest < ActionController::TestCase
  fixtures :datasets

  def setup
    @controller = DatasetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:datasets)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_dataset
    old_count = Dataset.count
    post :create, :dataset => { }
    assert_equal old_count+1, Dataset.count
    
    assert_redirected_to dataset_path(assigns(:dataset))
  end

  def test_should_show_dataset
    get :show, :id => 5
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 5
    assert_response :success
  end
  
  def test_should_update_dataset
    put :update, :id => 5, :dataset => { }
    assert_redirected_to dataset_path(assigns(:dataset))
  end
  
  def test_should_destroy_dataset
    old_count = Dataset.count
    delete :destroy, :id => 5
    assert_equal old_count-1, Dataset.count
    
    assert_redirected_to datasets_path
  end
end
