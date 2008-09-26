require File.dirname(__FILE__) + '/../test_helper'
require 'publications_controller'

# Re-raise errors caught by the controller.
class PublicationsController; def rescue_action(e) raise e end; end

class PublicationsControllerTest < Test::Unit::TestCase
  fixtures :publications

  def setup
    @controller = PublicationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:publications)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_publications
    old_count = Publications.count
    post :create, :publications => { }
    assert_equal old_count+1, Publications.count
    
    assert_redirected_to publications_path(assigns(:publications))
  end

  def test_should_show_publications
    get :show, :id => 135
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 135
    assert_response :success
  end
  
  def test_should_update_publications
    pub = Publication.new
    put :update, :id => 135, :publications => { pub }
    assert_redirected_to publications_path(assigns(:publications))
  end
  
  def test_should_destroy_publications
    old_count = Publications.count
    delete :destroy, :id => 135
    assert_equal old_count-1, Publications.count
    
    assert_redirected_to publications_path
  end
end
