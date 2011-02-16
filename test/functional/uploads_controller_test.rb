require File.expand_path('../../test_helper',__FILE__) 

class UploadsControllerTest < ActionController::TestCase

  def setup
    @controller.current_user = User.new(:role=>'admin')
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should assign upload in new" do
    get :new
    assert assigns(:upload)
  end

  #TODO Make sure these next two are tested with an actual file uploaded, prob in cucumber
  test "should create upload" do
    assert_difference 'Upload.count' do
      post :create, :upload => {:title => 'Title', :abstract => 'Abstract', :owners => 'Me'}
    end
  end
  
  test "should show an upload" do
    post :create, :upload => {:title => 'Title', :abstract => 'Abstract', :owners => 'Me'}
    @upload = Upload.find(:first)
    get :show, :id => @upload.id
    assert_response :success
  end
  
  context 'GET :new in the glbrc subdomain' do
    setup do
      get :new, :requested_subdomain => 'glbrc'
    end
    
    should render_template 'new'
    should render_with_layout(:glbrc)
  end
end
