require File.expand_path('../../test_helper',__FILE__)
require 'affiliations_controller'

class AffiliationsControllerTest < ActionController::TestCase

  def setup
    #TODO test with admin and non admin users
    signed_in_as_admin
  end

  def teardown
  end

  context "on GET to :new" do
    setup do
      get :new
    end

    should render_template :new
  end

  context 'on POST :create' do
    setup do
      post :create, :affiliation => {}
    end

    should redirect_to("the affiliation page") {affiliation_url(assigns(:affiliation))}
  end

  context 'an affiliation exists.' do
    setup do
      @affiliation = FactoryGirl.create(:affiliation)
    end

    context "PUT :update to affiliation with valid attributes" do
      setup do
        put :update, :id => @affiliation, :affiliation => {}
      end

      should redirect_to("the affiliation page") {affiliation_url(@affiliation)}
      should set_the_flash
    end
  end
end
