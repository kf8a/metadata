require 'test_helper'

class UploadsControllerTest < ActionController::TestCase
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
      file_name = '/../SingingSongtestfile.txt'
      post :create, :upload => {:title => 'Title', :abstract => 'Abstract', :owners => 'Me', :file => fixture_file_upload(file_name)}
    end
  end
  
  test "should show an upload" do
    file_name = '/../SingingSongtestfile.txt'
    post :create, :upload => {:title => 'Title', :abstract => 'Abstract', :owners => 'Me', :file => fixture_file_upload(file_name)}
    @upload = Upload.find(:first)
    get :show, :id => @upload
    assert_response :success
  end
end
