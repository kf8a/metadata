require File.expand_path('../../test_helper',__FILE__) 

class UploadsControllerTest < ActionController::TestCase

  def setup
    #TODO test as non-admin
    signed_in_as_admin
  end

  context 'GET :index' do
    setup do
      get :index
    end

    should respond_with :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should assign upload in new" do
    get :new
    assert assigns(:upload)
  end

  test "should create upload" do
    assert_difference 'Upload.count' do
      post :create, :upload => {:title => 'Title', :abstract => 'Abstract', :owners => 'Me'}
    end
  end

  test "should show an upload" do
    post :create, :upload => {:title => 'Title', :abstract => 'Abstract', :owners => 'Me'}
    @upload = Upload.first
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
