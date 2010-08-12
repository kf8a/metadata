require File.dirname(__FILE__) + '/../test_helper'
require 'protocols_controller'

class ProtocolsControllerTest < ActionController::TestCase
  #fixtures :protocols

  def setup
    generate_websites_and_protocols
    #TODO test with admin and non admin users
    @controller.current_user = User.new(:role => 'admin')
  end
  
  context 'GET: index in lter (default) subdomain' do
    setup do
       get :index, :requested_subdomain => 'lter'
     end

     should render_template 'index'

     should 'only have lter protocols' do
       assert assigns(:protocols) == [@protocol]
     end
    
  end

  context "GET :index / glbrc subdomain" do
    setup do
      get :index, :requested_subdomain => 'glbrc'
    end

    should render_template 'glbrc_index'
    
    should 'only have glbrc protocols' do
      assert assigns(:protocols) == [@glbrc_protocol]
    end
  end
  
  context 'GET :show in glbrc subdomain with lter_protocol' do
    setup do 
      get :show, :id => @protocol, :requested_subdomain => 'glbrc'
    end
    
    should redirect_to("the index page") {protocols_url()}
  end

  context 'GET :show in glbrc subdomain with glbrc protocol' do
    setup do 
      get :show, :id => @glbrc_protocol, :requested_subdomain => 'glbrc'
    end
    
    should respond_with(:success)
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
  
  private

  def generate_websites_and_protocols
    @website = Factory.create(:website, :name=>'lter')
    @protocol = Factory.create(:protocol, :title => 'lter_protocol')
    @website.protocols << @protocol
    
    @glbrc_website = Factory.create(:website, :name=>'glbrc')
    @glbrc_protocol = Factory.create(:protocol, :title => 'glbrc protocol')
    @glbrc_website.protocols << @glbrc_protocol
  end

end
