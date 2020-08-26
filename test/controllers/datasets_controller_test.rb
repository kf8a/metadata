# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class DatasetsControllerTest < ActionController::TestCase
  def setup
    @dataset = FactoryBot.create(:datatable).dataset
    FactoryBot.create(:dataset)

    # TODO: test with admin and non admin users
    signed_in_as_admin
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_dataset
    old_count = Dataset.count
    post :create, params: { dataset: { abstract: 'some text' } }
    assert_equal old_count + 1, Dataset.count

    assert_redirected_to dataset_path(assigns(:dataset))
  end

  context "POST :create with invalid parameters" do
    setup do
      post :create, params: { dataset: { abstract: nil } }
    end

    should render_template :new
    should_not set_flash
  end

  def test_should_show_dataset
    get :show, params: { id: @dataset }
    assert_response :success
  end

  context 'GET :show the dataset in eml' do
    setup do
      get :show, params: { id: @dataset, format: :eml }
    end

    should respond_with :success
  end

  context "an lter dataset" do
    setup do
      lter_website = Website.find_by(name: 'lter')
      lter_website ||= FactoryBot.create(:website, name: 'lter')
      @lterdataset = FactoryBot.create(:dataset, website: lter_website)
    end

    context "GET :show the dataset / 'glbrc' subdomain" do
      setup do
        get :show, params: { id: @lterdataset, requested_subdomain: 'glbrc' }
      end

      should_not respond_with :success
    end

    context "GET :show the dataset / 'lter' subdomain" do
      setup do
        get :show, params: { id: @lterdataset, requested_subdomain: 'lter' }
      end

      should respond_with :success
    end
  end

  def test_should_get_edit
    get :edit, params: { id: @dataset }
    assert_response :success
    assert assigns(:dataset)
    assert assigns(:people)
    assert assigns(:roles)
  end

  def test_should_update_dataset
    put :update, params: { id: @dataset, dataset: { title: "Title updated" } }
    assert_redirected_to dataset_path(assigns(:dataset))
  end

  context "PUT :update with invalid parameters" do
    setup do
      put :update, params: { id: @dataset, dataset: { abstract: nil } }
    end

    should render_template :edit
    should_not set_flash
  end

  def test_should_destroy_dataset
    old_count = Dataset.count
    delete :destroy, params: { id: @dataset }
    assert_equal old_count - 1, Dataset.count

    assert_redirected_to datasets_path
  end

  context 'GET index' do
    setup do
      @dataset = FactoryBot.create(:dataset)
      FactoryBot.create(:dataset)

      get :index
    end

    should redirect_to('the datatable page') { datatables_path }
    should_not set_flash
  end

  context 'eml harvester document' do
    setup do
      @dataset = FactoryBot.create(:dataset)
      get :index, params: { format: :eml }
    end

    should 'be succesful'
  end

  context "eml harvester document is used as parameter for index" do
    setup do
      @dataset = FactoryBot.create(:dataset)
      get :index, params: { dataset: @dataset }
    end

    should respond_with :success
  end
end
