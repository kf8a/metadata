require File.dirname(__FILE__) + '/../test_helper'
require 'datatables_controller'

# Re-raise errors caught by the controller.
class DatatablesController; def rescue_action(e) raise e end; end

class DatatablesControllerTest < ActionController::TestCase
  fixtures :datatables

  def setup
    @controller = DatatablesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
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
    post :create, :datatable => { }
    assert_equal old_count+1, Datatable.count
    
    assert_redirected_to datatable_path(assigns(:datatable))
  end

  def test_should_show_datatable
    get :show, :id => 24
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 24
    assert_response :success
  end
  
  def test_should_update_datatable
    put :update, :id => 24, :datatable => { }
    assert_redirected_to datatable_path(assigns(:datatable))
  end
  
  def test_should_destroy_datatable
    old_count = Datatable.count
    delete :destroy, :id => 24
    assert_equal old_count-1, Datatable.count
    
    assert_redirected_to datatables_path
  end
end
