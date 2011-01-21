require 'template_handler'

class ApplicationController < ActionController::Base
  protect_from_forgery

  include Clearance::Authentication

  layout :site_layout

  before_filter :set_crumbs, :set_subdomain_request, :set_title

   LOCAL_IPS =/^127\.0\.0\.1$|^192\.231\.113\.|^192\.108\.190\.|^192\.108\.188\.|^192\.108\.191\./

   def trusted_ip?
     LOCAL_IPS =~ request.remote_ip
   end

  private

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

  def request_subdomain(requested_subdomain=current_subdomain)
    requested_subdomain = current_subdomain if requested_subdomain.blank?
    requested_subdomain = 'lter' unless valid_subdomain?(requested_subdomain)
    return requested_subdomain
  end

  def valid_subdomain?(subdomain)
    ['lter','glbrc'].include?(subdomain)
  end

  def render_subdomain(page=action_name, mycontroller=controller_name, domain=@subdomain_request)
    handler = TemplateHandler.new(page, mycontroller, domain)
    render :template => handler.correct_template
  end
end
