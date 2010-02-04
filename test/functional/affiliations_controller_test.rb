require File.dirname(__FILE__) + '/../test_helper'
require 'affiliations_controller'

# Re-raise errors caught by the controller.
class AffiliationsController; def rescue_action(e) raise e end; end

class AffiliationsControllerTest < ActionController::TestCase
  fixtures :affiliations

  def setup
    @controller = AffiliationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

end
