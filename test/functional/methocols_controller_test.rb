require File.dirname(__FILE__) + '/../test_helper'
require 'methocols_controller'

# Re-raise errors caught by the controller.
class MethocolsController; def rescue_action(e) raise e end; end

class MethocolsControllerTest < Test::Unit::TestCase
  fixtures :methocols

  def setup
    @controller = MethocolsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:methocols)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_methocol
    old_count = Methocol.count
    post :create, :methocol => { }
    assert_equal old_count+1, Methocol.count
    
    assert_redirected_to methocol_path(assigns(:methocol))
  end

  def test_should_show_methocol
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_methocol
    put :update, :id => 1, :methocol => { }
    assert_redirected_to methocol_path(assigns(:methocol))
  end
  
  def test_should_destroy_methocol
    old_count = Methocol.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Methocol.count
    
    assert_redirected_to methocols_path
  end
end
