require File.expand_path('../../test_helper',__FILE__)

class DataContributionsControllerTest < ActionController::TestCase

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

end
