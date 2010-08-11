require 'test_helper'

class PermissionsControllerTest < ActionController::TestCase

  context "a protected and owned datatable" do
    setup do
      @datatable = Factory.create(:protected_datatable)
      @owner = Factory.create(:email_confirmed_user)
      Factory.create(:ownership, :user => @owner, :datatable => @datatable)
    end
    
    context "and GET :show the datatable's permissions" do
      setup do
        get :show, :datatable => @datatable
      end
      
      should respond_with :success
    end
  end

end
