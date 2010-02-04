require File.dirname(__FILE__) + '/../test_helper'
require 'units_controller'

# Re-raise errors caught by the controller.
class UnitsController; def rescue_action(e) raise e end; end

class UnitsControllerTest < ActionController::TestCase
  def setup
    @controller = UnitsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
