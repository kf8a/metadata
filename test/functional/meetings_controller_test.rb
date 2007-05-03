require File.dirname(__FILE__) + '/../test_helper'
require 'meetings_controller'

# Re-raise errors caught by the controller.
class MeetingsController; def rescue_action(e) raise e end; end

class MeetingsControllerTest < Test::Unit::TestCase
  def setup
    @controller = MeetingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
