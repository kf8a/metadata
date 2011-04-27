require File.expand_path('../../test_helper',__FILE__)

class DatasetsControllerTest < ActionController::TestCase


  def setup
    @dataset = Factory.create(:dataset)
    Factory.create(:dataset)

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

  context 'GET :show the datatable in eml' do
    setup do
      get :show, :id => @dataset, :format => :eml
    end

    should respond_with :success
    should 'be the exact right eml' do
      proper_eml = "xsi:schemaLocation='eml://ecoinformatics.org/eml-2.1.0 eml.xsd' xmlns:set='http://exslt.org/sets' xmlns:stmml='http://www.xml-cml.org/schema/stmml' system='KBS LTER' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'><access authSystem='knb' order='allowFirst' scope='document'><allow><principal>uid=KBS,o=lter,dc=ecoinformatics,dc=org</principal><permission>all</permission></allow><allow><principal>public</principal><permission>read</permission></allow></access><dataset><title>KBS001</title><creator id='KBS LTER'><positionName>Data Manager</positionName></creator><abstract><para>&lt;p&gt;some new dataset&lt;/p&gt;</para></abstract><keywordSet><keyword keywordType='place'>LTER</keyword><keyword keywordType='place'>KBS</keyword><keyword keywordType='place'>Kellogg Biological Station</keyword><keyword keywordType='place'>Hickory Corners</keyword><keyword keywordType='place'>Michigan</keyword><keyword keywordType='place'>Great Lakes</keyword></keywordSet><contact><organizationName>Kellogg Biological Station</organizationName><positionName>Data Manager</positionName><address scope='document'><deliveryPoint>Kellogg Biological Station</deliveryPoint><deliveryPoint>3700 East Gull Lake Drive</deliveryPoint><city>Hickory Corners</city><administrativeArea>Mi</administrativeArea><postalCode>49060</postalCode><country>USA</country></address><electronicMailAddress>data.manager@kbs.msu.edu</electronicMailAddress><onlineUrl>http://lter.kbs.msu.edu</onlineUrl></contact></dataset><additionalMetadata><metadata><stmml:unitList xsi:schemaLocation='http://www.xml-cml.org/schema/stmml http://lter.kbs.msu.edu/Data/schemas/stmml.xsd'/></metadata></additionalMetadata></eml:eml>"
      assert_includes response.body, proper_eml
    end
  end

  context "an lter dataset" do
    setup do
      lter_website = Website.find_by_name('lter')
      lter_website = Factory.create(:website, :name => 'lter') unless lter_website
      @lterdataset = Factory.create(:dataset, :website => lter_website)
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
      @dataset = Factory.create(:dataset)
      Factory.create(:dataset)

      get :index
    end

    should assign_to :datasets
    should assign_to :people
    should assign_to :themes

    should redirect_to('the datatable page') {datatables_path}
    should_not set_the_flash

  end


  context 'eml harvester document' do
    setup do
      @dataset = Factory.create(:dataset)
      get :index, :format => :eml
    end

    should 'be succesful'
  end

  context "eml harvester document is used as parameter for index" do
    setup do
      @dataset = Factory.create(:dataset)
      get :index, :Dataset => @dataset
    end

    should respond_with :success
    should respond_with_content_type :eml
  end
end
