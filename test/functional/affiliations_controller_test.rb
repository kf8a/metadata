require File.dirname(__FILE__) + '/../test_helper'
require 'affiliations_controller'

# Re-raise errors caught by the controller.
class AffiliationsController; def rescue_action(e) raise e end; end

class AffiliationsControllerTest < ActionController::TestCase
#  fixtures :affiliations

  def setup
    #TODO test with admin and non admin users
    @controller.current_user = User.new(:role => 'admin')
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
