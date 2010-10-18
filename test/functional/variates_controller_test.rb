require File.expand_path('../../test_helper',__FILE__) 

class VariatesControllerTest < ActionController::TestCase
  #fixtures :variates

  def setup
    @controller = VariatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @variate = Factory.create(:variate)
    Factory.create(:variate)
     @controller.current_user = Factory.create :admin_user
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
    get :show, :id => @variate.id
    assert_response :success
  end

  def test_should_get_edit  
    get :edit, :id => @variate.id
    assert_response :success
  end
  
  def test_should_update_variate
    put :update, :id => @variate, :variate => { }
    assert_redirected_to variate_path(assigns(:variate))
  end
  
  def test_should_destroy_variate  
    old_count = Variate.count
    delete :destroy, :id => @variate
    assert_equal old_count-1, Variate.count
    
    assert_redirected_to variates_path
  end
 
end
