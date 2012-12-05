require File.expand_path('../../test_helper',__FILE__)

class PeopleControllerTest < ActionController::TestCase
  fixtures :people, :role_types, :roles,  :affiliations

  context 'not signed in' do

     context "and GET :index" do
       setup do
         get :index
       end

       should respond_with :success
     end

     context 'GET :edit' do
       setup do
         get :edit, :id => 1
       end
       should respond_with :redirect
       should redirect_to("the sign in page") {sign_in_path}
     end

     context 'POST :update' do
       setup do
          put :update, :id => '107', :person=>{"city"=>"Hickory Corners", "postal_code"=>"49060", "title"=>"", "lter_role_ids"=>["15"], "country"=>"USA", "sur_name"=>"Grillo (REU)", "url"=>"", "street_address"=>"", "given_name"=>"Michael", "sub_organization"=>"Kellogg Biological Station", "fax"=>"", "phone"=>"", "organization"=>"Michigan State University", "locale"=>"MI", "friendly_name"=>"Mike", "middle_name"=>"", "email"=>"grillom1@msu.edu"}
       end

       should respond_with :redirect
       should redirect_to("the sign in page") {sign_in_path}
     end
   end

   context 'signed in as admin' do

   end

  def setup
    #TODO test with admin and non admin users
    signed_in_as_admin
  end

  context "GET :index" do
    setup do
      get :index
    end

    teardown do
      @controller.expire_fragment(:action => :index)
    end

    should respond_with :success
    should render_template :index
    should assign_to :people
    should assign_to :roles
    should "create index cache" do
      assert @controller.fragment_exist?(:controller => "people", :action => "index")
    end
  end

  context "GET :alphabetical" do
    setup do
      Rails.cache.clear
      get :alphabetical
    end

    should render_template :alphabetical
    should assign_to :people
    should "create alphabetical cache" do
      assert @controller.fragment_exist?(:controller => "people", :action => "alphabetical")
    end
  end

  context "GET :emeritus" do
    setup do
      Rails.cache.clear
      get :emeritus
    end

    should render_template :emeritus
    should assign_to :people
    should assign_to :roles
    should "create emeritus cache" do
      assert @controller.fragment_exist?(:controller => "people", :action => "emeritus")
    end
  end

  context "GET :show for a person" do
    setup do
      @person = FactoryGirl.create(:person)
      get :show, :id => @person
    end

    should respond_with :success

    should render_template :show
    # by default render the lter layout
    should render_with_layout 'lter'
    should assign_to :person
  end

  context "GET: show for subdomain glbrc" do
    setup do
       @person = FactoryGirl.create(:person)
      get :show, :id => @person, :requested_subdomain => 'glbrc'
    end

    should respond_with :success

    should render_template :show
    should render_with_layout 'glbrc'
    should assign_to :person
  end

  context "GET: show for subdomain lter" do
    setup do
      @person = FactoryGirl.create(:person)
      get :show, :id => @person, :requested_subdomain => 'lter'
    end

     should respond_with :success

     should render_template :show
     should render_with_layout 'lter'
     should assign_to :person
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  context 'An index cache already exists' do
    setup do
      get :index
      assert @controller.fragment_exist?(:controller => "people", :action => "index")
    end

    context 'Post :create' do
      setup do
        @old_count = Person.count
        post :create, :person => { }
      end

      should redirect_to("the sign in page") {person_path(assigns(:person))}
      should 'create a person' do
        assert_equal @old_count+1, Person.count
      end
      should 'invalidate the index cache' do
        refute @controller.fragment_exist?(:controller => "people", :action => "index")
      end
    end
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

  def test_update_should_invalidate_cache
    get :index

    put :update, :id => '107', :person=>{"city"=>"Hickory Corners", "postal_code"=>"49060", "title"=>"", "lter_role_ids"=>["15"], "country"=>"USA", "sur_name"=>"Grillo (REU)", "url"=>"", "street_address"=>"", "given_name"=>"Michael", "sub_organization"=>"Kellogg Biological Station", "fax"=>"", "phone"=>"", "organization"=>"Michigan State University", "locale"=>"MI", "friendly_name"=>"Mike", "middle_name"=>"", "email"=>"grillom1@msu.edu"}

    #assert File.exists? ActionController::Base.page_cache_path(@request.path)
  end

  #Trying to update a person with invalid parameters should be tested once any parameters count as invalid.

  def test_should_destroy_person
    old_count = Person.count
    delete :destroy, :id => 304
    assert_equal old_count-1, Person.count

    assert_redirected_to people_path
  end
end
