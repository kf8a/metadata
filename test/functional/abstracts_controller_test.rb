require File.dirname(__FILE__) + '/../test_helper'
require 'abstracts_controller'

# Re-raise errors caught by the controller.
class AbstractsController; def rescue_action(e) raise e end; end

class AbstractsControllerTest < ActionController::TestCase

  def setup
    @meeting = Factory.create(:meeting)
    
    #TODO test with admin and non admin users
    @controller.current_user = User.new(:role => 'admin')  
  end
  
  def teardown
    Meeting.destroy_all
    Abstract.destroy_all
  end
  
  test "should get index" do
    get :index
    assert assigns(:abstracts)
    assert_response :success
  end
  
  test "should get new" do
    get :new, :meeting => @meeting
    assert_response :success
  end
  
  test "should create abstract with valid parameters" do
    assert_difference "Abstract.count" do
      post :create, :abstract => {:title => 'soil pH', :meeting_id => @meeting.id}
    end

    assert_redirected_to meeting_url(@meeting)
  end
  
  test "should not create abstract with invalid parameters" do
    assert_no_difference "Abstract.count" do
#figure out how to make this invalid      post :create, :abstract => {
    end
  end
  
end

