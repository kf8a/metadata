require File.dirname(__FILE__) + '/../test_helper'
require 'protocols_controller'

# Re-raise errors caught by the controller.
class MethocolsController; def rescue_action(e) raise e end; end

class MethocolsControllerTest < Test::Unit::TestCase
  fixtures :protocols

  def setup
    @controller = MethocolsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:protocols)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_protocol
    old_count = Methocol.count
    post :create, :protocol => { }
    assert_equal old_count+1, Methocol.count
    
    assert_redirected_to protocol_path(assigns(:protocol))
  end

  def test_should_show_protocol
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_protocol
    put :update, :id => 1, :protocol => { }
    assert_redirected_to protocol_path(assigns(:protocol))
  end
  
  def test_should_destroy_protocol
    old_count = Methocol.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Methocol.count
    
    assert_redirected_to protocols_path
  end
end
