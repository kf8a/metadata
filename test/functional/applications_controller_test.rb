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
    
    def testpagechoose
      @page_chosen = template_choose(params[:page_req])
      render :text => "Something needs to be rendered"
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
    
    context "template choose function" do
      setup do
        @controller.current_user = User.new(:role => 'admin')  
      end
      
      context "when a subdomain is requested which exists" do
        setup do
          # create a foo_index.html.erb page mock File
          File.stubs(:file?).returns(true)
          @controller.stubs(:current_subdomain).returns('lter')
          get :testpagechoose, :page_req => "index"
        end
        
        should respond_with(:success)
        should assign_to(:page_chosen).with("app/views/foo/lter_index.html.erb")
      end
      
      context "when a subdomain is requested which does not exist" do
        setup do
          #File.expects(:file?).with('app/view/foo/index.html.erb').returns(false)
          File.stubs(:file?).returns(false)
          get :testpagechoose, :page_req => "index"
        end

        should respond_with(:success)
        should assign_to(:page_chosen).with("app/views/foo/index.html.erb")
      end
      
      context "when a template is in the database" do
        setup do
          @controller.stubs(:current_subdomain).returns('lter')
          # The File.stub is problematic since we are calling File.file? twice in the implementation
          # to test for the existance of different files
          File.stubs(:file?).returns(true)
          
          lter_website = Factory.create(:website, :name => 'lter')
          index_layout = Factory.create(:template, 
                    :website_id => lter_website.id,
                    :controller => 'foo',
                    :action     => 'index',
                    :layout     => '<h3 id="correct">testpagechoose</h3>')
          
          get :testpagechoose,:page_req => "index"
        end

        should respond_with(:success)
        should assign_to(:page_chosen).with("app/views/foo/liquid_index.html.erb")
      end
    end
  end
end

