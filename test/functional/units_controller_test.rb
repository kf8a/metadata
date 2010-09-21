require File.dirname(__FILE__) + '/../test_helper'
require 'units_controller'

# Re-raise errors caught by the controller.
class UnitsController; def rescue_action(e) raise e end; end

class UnitsControllerTest < ActionController::TestCase
  def setup

    #TODO test with admin and non admin users
    @controller.current_user = Factory.create :admin_user
  end

  context "GET :index" do
    setup do
      get :index
    end
    
    should respond_with :success
    should assign_to :units
  end
  
  context "GET :edit" do
    setup do
      @unit = Factory.create(:unit)
      get :edit, :id => @unit
    end
    
    should respond_with :success
    should assign_to(:unit).with(@unit)
  end
  
  context "PUT :update" do
    setup do
      @unit = Factory.create(:unit)
      put :update, :id => @unit
    end
    
    should redirect_to("the units's page") {unit_url(@unit)}
    should assign_to(:unit).with(@unit)
  end
  
  context "GET :show" do
    setup do
      @unit = Factory.create(:unit)
      get :show, :id => @unit
    end
    
    should respond_with :success
    should assign_to(:unit).with(@unit)
  end
end
