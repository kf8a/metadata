require File.dirname(__FILE__) + '/../test_helper'
require 'affiliations_controller'

# Re-raise errors caught by the controller.
class AffiliationsController; def rescue_action(e) raise e end; end

class AffiliationsControllerTest < ActiveSupport::TestCase
  fixtures :affiliations

  def setup
    @controller = AffiliationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:affiliations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_affiliation
    old_count = Affiliation.count
    post :create, :affiliation => { }
    assert_equal old_count+1, Affiliation.count
    
    assert_redirected_to affiliation_path(assigns(:affiliation))
  end

  def test_should_show_affiliation
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_affiliation
    put :update, :id => 1, :affiliation => { }
    assert_redirected_to affiliation_path(assigns(:affiliation))
  end
  
  def test_should_destroy_affiliation
    old_count = Affiliation.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Affiliation.count
    
    assert_redirected_to affiliations_path
  end
end
