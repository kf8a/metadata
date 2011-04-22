require 'liquid_resolver'
require 'subdomain_resolver'

class ApplicationController < ActionController::Base
  protect_from_forgery

  include Clearance::Authentication

  layout :site_layout

  before_filter :set_crumbs, :set_subdomain_request, :extra_views, :set_title

  respond_to :html, :xml, :json

   LOCAL_IPS =/^127\.0\.0\.1$|^192\.231\.113\.|^192\.108\.190\.|^192\.108\.188\.|^192\.108\.191\./

   def trusted_ip?
     LOCAL_IPS =~ request.remote_ip
   end

  private

  def extra_views
    prepend_view_path SubdomainResolver.new(@subdomain_request)
    prepend_view_path LiquidResolver.new(@subdomain_request)
  end

  def admin?
    unless current_user.try(:role) == 'admin'
      flash[:notice] = "You must be signed in as an administrator in order to access this page"
      deny_access
      return false
    end
  end

  def set_crumbs
    @crumbs = []
  end

  def set_subdomain_request
    @subdomain_request = request_subdomain(params[:requested_subdomain])
  end

  def set_title
     @title = @subdomain_request.upcase
  end

  def site_layout
    request_subdomain(params[:requested_subdomain])
  end

  def request_subdomain(requested_subdomain)
    valid_subdomain?(requested_subdomain) ? requested_subdomain : get_subdomain_from_request
  end

  def get_subdomain_from_request
    request.host.downcase.include?("glbrc") ? "glbrc" : "lter" 
  end

  def valid_subdomain?(subdomain)
    ['lter','glbrc'].include?(subdomain)
  end

  def website
    @website ||= Website.find_by_name(@subdomain_request) || Website.first
  end
end
