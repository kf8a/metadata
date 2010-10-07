require 'test_helper'
require 'affiliations_controller'

class AffiliationsControllerTest < ActionController::TestCase
#  fixtures :affiliations

  def setup
    #TODO test with admin and non admin users
    @controller.current_user = Factory.create :admin_user
  end

  def teardown
  end
  
  context "on GET to :new" do
    setup do
      get :new
    end

    should render_template :new
  end


end
