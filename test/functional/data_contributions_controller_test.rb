require File.dirname(__FILE__) + '/../test_helper'

class DataContributionsControllerTest < ActionController::TestCase

  def setup
    
    #TODO test with admin and non admin users
    @controller.current_user = Factory.create :admin_user
  end
  
  def teardown
  end
  
  context "on GET to :new" do
    setup do
      get :create
    end

    should render_template :new
  end

end
