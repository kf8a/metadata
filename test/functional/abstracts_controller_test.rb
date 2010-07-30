require File.dirname(__FILE__) + '/../test_helper'
require 'abstracts_controller'

# Re-raise errors caught by the controller.
class AbstractsController; def rescue_action(e) raise e end; end

class AbstractsControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert assigns(:abstracts)
    assert_response :success
  end
  
end

