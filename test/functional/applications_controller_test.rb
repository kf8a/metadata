require File.dirname(__FILE__) + '/../test_helper'
require 'application_controller'

# Re-raise errors caught by the controller.
class ApplicationController; def rescue_action(e) raise e end; end

class ApplicationControllerTest < ActionController::TestCase


  class FooController < ApplicationController
  #This is a fake controller in which we can test the various things that should apply to all controllers.
  
    before_filter :admin?, :only => [:testadmin]
  
    def testadmin
      render :text => "You are an admin"
    end
  end
  
  class FooControllerTest < ActionController::TestCase

    context "the admin function" do
      
      context "when nobody is logged in" do
        setup do
          @controller.current_user = nil
          get :testadmin
        end
        
        should_not respond_with :success
      end
      
      context "when a non-admin is logged in" do
        setup do
          @controller.current_user = User.new(:role => 'notadmin')  
          get :testadmin
        end
        
        should_not respond_with :success
      end
      
      context "when an admin is logged in" do
        setup do
          @controller.current_user = User.new(:role => 'admin')  
          get :testadmin
        end
        
        should respond_with :success
      end
    end
  end
end

