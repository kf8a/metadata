require File.dirname(__FILE__) + '/../test_helper'
require 'meeting_abstracts_controller'

# Re-raise errors caught by the controller.
class MeetingAbstractsController; def rescue_action(e) raise e end; end

class MeetingAbstractsControllerTest < ActiveSupport::TestCase
  def setup
    @controller = MeetingAbstractsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
