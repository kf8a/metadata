require File.dirname(__FILE__) + '/../test_helper'
require 'protocols_controller'

# # Re-raise errors caught by the controller.
# class ProtocolsController; def rescue_action(e) raise e end; end

class ProtocolsControllerTest < ActionController::TestCase
  #fixtures :protocols

  def setup
    @protocol = Factory.create(:protocol)
    
    #TODO test with admin and non admin users
    @controller.current_user = User.new(:role => 'admin')
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:protocols)
  end

  context "GET :index / 'glbrc' subdomain" do
    setup do
      @controller.stubs(:current_subdomain).returns('glbrc')
      get :index #, :requested_subdomain => 'glbrc'
    end

    should render_template 'glbrc_index'
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_protocol
     old_count = Protocol.count
     post :create, :protocol => {:dataset_id => 35 }
     assert_equal old_count+1, Protocol.count
     
     assert_redirected_to protocol_path(assigns(:protocol))
   end

  def test_should_show_protocol
    get :show, :id => @protocol
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => @protocol
    assert_response :success
  end
  
  def test_should_update_protocol
    put :update, :id => @protocol, :protocol => { }
    assert_redirected_to protocol_path(assigns(:protocol))
  end
  
  def test_should_destroy_protocol
    old_count = Protocol.count
    delete :destroy, :id => @protocol
    assert_equal old_count-1, Protocol.count
    
    assert_redirected_to protocols_path
  end
  
  context 'POST with website' do
    setup do
      @protocol = Factory.create(:protocol)
      post :create, :id => @protocol, :websites=>['2']
    end
    
    should assign_to :protocol
    should redirect_to("the show page") {protocol_url(assigns(:protocol))}
  end
end
