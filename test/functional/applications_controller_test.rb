require File.expand_path('../../test_helper',__FILE__) 
require 'application_controller'

class ApplicationControllerTest < ActionController::TestCase

  class FooController < ApplicationController
  #This is a fake controller in which we can test the various things that should apply to all controllers.

    before_filter :admin?, :only => [:testadmin]
    helper PeopleHelper

    def testadmin
      render :text => "You are an admin"
    end

    def testpagechoose
      sub = params[:sub]
      con = params[:cont]
      page_req = params[:page_req]

      #necessary variables to load the pages below
      @themes = Theme.roots
      @protocols = Protocol.all
      @people = Person.order('sur_name')
      @roles = RoleType.find_by_name('lter').roles.all(:order => :seniority, :conditions =>['name not like ?','Emeritus%'])

      render_subdomain(page_req, con, sub)
    end
  end

  class FooControllerTest < ActionController::TestCase

    context "the admin function" do

      context "when nobody is logged in" do
        setup do
          sign_out
          get :testadmin
        end

        should_not respond_with :success
      end

      context "when a non-admin is logged in" do
        setup do
          user = User.new()
          user.role = 'nonadmin'
          sign_in_as(user)
          get :testadmin
        end

        should_not respond_with :success
      end

      context "when an admin is logged in" do
        setup do
          signed_in_as_admin
          get :testadmin
        end

        should respond_with :success
      end
    end

    #TODO: Rewrite these tests to use the resolvers
#    context "template choose function" do
#      setup do
#        signed_in_as_admin
#        FactoryGirl.create(:role_type, :name => 'lter') unless RoleType.find_by_name('lter')
#      end
#
#      context "when a subdomain is requested which exists" do
#        setup do
#          get :testpagechoose, :sub => "glbrc", :cont => "protocols", :page_req => "index"
#        end
#
#        should respond_with(:success)
#        should render_template "protocols/glbrc_index"
#      end
#
#      context "when a subdomain is requested which does not exist" do
#        setup do
#          get :testpagechoose, :sub => "lter", :cont => "people", :page_req => "index"
#        end
#
#        should respond_with(:success)
#        should render_template "people/index"
#      end
#    end
  end
end
