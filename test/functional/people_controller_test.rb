require File.dirname(__FILE__) + '/../test_helper'
require 'people_controller'

# Re-raise errors caught by the controller.
class PeopleController; def rescue_action(e) raise e end; end

class PeopleControllerTest < ActionController::TestCase
  fixtures :people, :role_types, :roles,  :affiliations
  
  def setup
    #TODO test with admin and non admin users
    @controller.current_user = User.new(:role => 'admin')
  end
  
  def teardown
    @controller.expire_fragment(%r{.*})
  end

  context "GET :index" do
    setup do
      get :index
    end
    
    should respond_with :success
    should render_template :index
    should assign_to :people
    should assign_to :roles
  end
  
  context "GET :alphabetical" do
    setup do
      get :alphabetical
    end
    
    should render_template :alphabetical
    should assign_to :people
  end

  context "GET :emeritus" do
    setup do
      get :emeritus
    end
    
    should render_template :emeritus
    should assign_to :people
    should assign_to :roles
  end
  
  context "GET :show for a person" do
    setup do
      @person = Factory.create(:person)
      get :show, :id => @person
    end
    
    should render_template :show
    should assign_to :person
  end

  
  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_person
    old_count = Person.count
    post :create, :person => { }
    assert_equal old_count+1, Person.count
    
    assert_redirected_to person_path(assigns(:person))
  end
  
  #Trying to create a person with invalid parameters should be tested once any parameters are invalid.
  
  def test_should_get_edit
    get :edit, :id => 107
    assert_response :success
  end
  
  def test_should_update_person
    put :update, :id => '107', :person=>{"city"=>"Hickory Corners", "postal_code"=>"49060", "title"=>"", "lter_role_ids"=>["15"], "country"=>"USA", "sur_name"=>"Grillo (REU)", "url"=>"", "street_address"=>"", "given_name"=>"Michael", "sub_organization"=>"Kellogg Biological Station", "fax"=>"", "phone"=>"", "organization"=>"Michigan State University", "locale"=>"MI", "friendly_name"=>"Mike", "middle_name"=>"", "email"=>"grillom1@msu.edu"}
    assert_redirected_to person_path(assigns(:person))
  end
  
  #Trying to update a person with invalid parameters should be tested once any parameters count as invalid.
  
  def test_should_destroy_person
    old_count = Person.count
    delete :destroy, :id => 304
    assert_equal old_count-1, Person.count
    
    assert_redirected_to people_path
  end
end
