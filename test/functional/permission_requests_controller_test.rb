require 'test_helper'

class PermissionRequestsControllerTest < ActionController::TestCase
  # Replace this with your real tests.

  context "a protected and owned datatable" do
    setup do
      @datatable = Factory.create(:protected_datatable)
      @owner = Factory.create(:email_confirmed_user)
      Factory.create(:ownership, :user => @owner, :datatable => @datatable)
    end
    
    context "and not signed in at all" do
      setup do
        @controller.current_user = nil
      end

      context "GET :new" do
        setup do
          get :new
        end
        
        should_not respond_with :success
      end
    end
  end
end
