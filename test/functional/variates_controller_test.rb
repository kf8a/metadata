require File.dirname(__FILE__) + '/../test_helper'
require 'variates_controller'

# Re-raise errors caught by the controller.
class VariatesController; def rescue_action(e) raise e end; end

class VariatesControllerTest < ActiveSupport::TestCase
  fixtures :variates

  def setup
    @controller = VariatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:variates)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_variate
    old_count = Variate.count
    post :create, :variate => { }
    assert_equal old_count+1, Variate.count
    
    assert_redirected_to variate_path(assigns(:variate))
  end

  def test_should_show_variate
    get :show, :id => 51
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 51
    assert_response :success
  end
  
  def test_should_update_variate
    put :update, :id => 51, :variate => { }
    assert_redirected_to variate_path(assigns(:variate))
  end
  
  def test_should_destroy_variate
    old_count = Variate.count
    delete :destroy, :id => 51
    assert_equal old_count-1, Variate.count
    
    assert_redirected_to variates_path
  end
end
