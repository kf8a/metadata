require File.dirname(__FILE__) + '/../test_helper'

class PublicationsControllerTest < ActionController::TestCase
 fixtures :publications, :treatments

  def setup
    #TODO test with admin and non admin users
    @controller.current_user = User.new(:role => 'admin')
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:publications)
  end
  
  context "GET :index with params[:alphabetical]" do
    setup do
      get :index, :alphabetical => true
    end
    
    should assign_to(:alphabetical).with(true)
    should assign_to(:decoration).with("by Author")
  end

  context "GET :index with params[:treatment]" do
    setup do
      get :index, :treatment => true
    end
    
    should assign_to(:alphabetical).with(true)
  end
  
  context "GET :index with params[:word]" do
    setup do
      get :index, :word => 'something'
    end
    
    should assign_to :publications
  end
  
  context "GET :index_by_treatment" do
    setup do
      get :index_by_treatment
    end
    
    should assign_to :studies
  end
  
  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_publication
    old_count = Publication.count
    post :create, :publication => {'year' => '2008', :citation => 'Jones et.al 2008'}
    assert_equal (old_count+1), Publication.count
    #TODO check redirect on create publication
    #assert_redirected_to publications_path(assigns(:publications))
  end
  
  context "POST :create with invalid parameters" do
    setup do
      post :create, :publication => {:citation => nil}
    end
    
    should_not set_the_flash
    should render_template :new
  end

  def test_should_show_publication
    get :show, :id => 135
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 135
    assert_response :success
  end
  
  def test_should_update_publication
    put :update, :id => 18, :publication => {'year' => '2008'} 
    assert_redirected_to publication_path(assigns(:publication))
  end
  
  context "PUT :update with invalid parameters" do
    setup do
      @publication = Factory.create(:publication)
      put :update, :id => @publication, :publication => {:citation => nil}
    end
    
    should_not set_the_flash
    should render_template :edit
    should assign_to :publication_types
    should assign_to :treatments
  end
  
  def test_should_destroy_publication
    old_count = Publication.count
    delete :destroy, :id => 18
    assert_equal old_count-1, Publication.count
    
    assert_redirected_to publications_path
  end
end
