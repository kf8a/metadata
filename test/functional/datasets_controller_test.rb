require File.expand_path('../../test_helper',__FILE__)

class DatasetsControllerTest < ActionController::TestCase


  def setup
    @dataset = FactoryGirl.create(:datatable).dataset
    FactoryGirl.create(:dataset)

    #TODO test with admin and non admin users
    signed_in_as_admin
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_dataset
    old_count = Dataset.count
    post :create, :dataset => {:abstract => 'some text' }
    assert_equal old_count+1, Dataset.count

    assert_redirected_to dataset_path(assigns(:dataset))
  end

  context "POST :create with invalid parameters" do
    setup do
      post :create, :dataset => {:abstract => nil}
    end

    should render_template :new
    should_not set_the_flash
  end

  def test_should_show_dataset
    get :show, :id => @dataset
    assert_response :success
  end

  context 'GET :show the dataset in eml' do
    setup do
      get :show, :id => @dataset, :format => :eml
    end

    should respond_with :success
  end

  context "an lter dataset" do
    setup do
      lter_website = Website.find_by_name('lter')
      lter_website = FactoryGirl.create(:website, :name => 'lter') unless lter_website
      @lterdataset = FactoryGirl.create(:dataset, :website => lter_website)
    end

    context "GET :show the dataset / 'glbrc' subdomain" do
      setup do
        get :show, :id => @lterdataset, :requested_subdomain => 'glbrc', :format =>'xml'
      end

      should_not respond_with :success
    end

    context "GET :show the dataset / 'lter' subdomain" do
      setup do
        get :show, :id => @lterdataset, :requested_subdomain => 'lter', :formt => 'xml'
      end

      should respond_with :success
    end
  end

  def test_should_get_edit
    get :edit, :id => @dataset
    assert_response :success
    assert assigns(:dataset)
    assert assigns(:people)
    assert assigns(:roles)
  end

  def test_should_update_dataset
    put :update, :id => @dataset, :dataset => { }
    assert_redirected_to dataset_path(assigns(:dataset))
  end

  context "PUT :update with invalid parameters" do
    setup do
      put :update, :id => @dataset, :dataset => {:abstract => nil}
    end

    should render_template :edit
    should_not set_the_flash
  end

  def test_should_destroy_dataset
    old_count = Dataset.count
    delete :destroy, :id => @dataset
    assert_equal old_count-1, Dataset.count

    assert_redirected_to datasets_path
  end

  context 'GET index' do
    setup do
      @dataset = FactoryGirl.create(:dataset)
      FactoryGirl.create(:dataset)

      get :index
    end

    should redirect_to('the datatable page') {datatables_path}
    should_not set_the_flash

  end


  context 'eml harvester document' do
    setup do
      @dataset = FactoryGirl.create(:dataset)
      get :index, :format => :eml
    end

    should 'be succesful'
  end

  context "eml harvester document is used as parameter for index" do
    setup do
      @dataset = FactoryGirl.create(:dataset)
      get :index, :Dataset => @dataset
    end

    should respond_with :success
  end
end
