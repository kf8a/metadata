# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)
require 'affiliations_controller'

class AffiliationsControllerTest < ActionController::TestCase
  def setup
    # TODO: test with admin and non admin users
    signed_in_as_admin
  end

  def teardown; end

  context "on GET to :new" do
    setup do
      get :new
    end

    should render_template :new
  end

  context 'on POST :create' do
    setup do
      post :create, params: { affiliation: { person_id: 1, role_id: 1 } }
    end

    should redirect_to("the affiliation page") { affiliation_url(assigns(:affiliation)) }
  end

  context 'an affiliation exists.' do
    setup do
      @affiliation = FactoryBot.create(:affiliation)
    end

    context "PUT :update to affiliation with valid attributes" do
      setup do
        put :update, params: { id: @affiliation, affiliation: { person_id: 1 } }
      end

      should redirect_to("the affiliation page") { affiliation_url(@affiliation) }
      should set_flash
    end
  end
end
