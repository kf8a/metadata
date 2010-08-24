# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Clearance::Authentication
    
  #before_filter :admin?, :except => [:index, :show] unless ENV["RAILS_ENV"] == 'development'
  before_filter :set_title, :set_crumbs
   
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
  
  def set_title
     @title = request_subdomain(params[:requested_subdomain]).upcase
  end
  
  def set_crumbs
    @crumbs = []
  end
  
  def site_layout
    request_subdomain(params[:requested_subdomain])
  end
  
  def request_subdomain(requested_subdomain=current_subdomain)
    requested_subdomain = current_subdomain if requested_subdomain.blank?
    requested_subdomain = 'lter' unless ['lter','glbrc'].include?(requested_subdomain)
    return requested_subdomain
  end
  
  def template_choose(domain, controller, page)
    non_domain_file_name = "app/views/" + controller + "/" + page + ".html.erb"
    domain_file_name = "app/views/" + controller + "/" + domain + "_" + page + ".html.erb"
    liquid_name = "app/views/" + controller + "/liquid_" + page + ".html.erb"

    name = non_domain_file_name
    name = domain_file_name if File.file?(domain_file_name)
    name = liquid_name if File.file?(liquid_name) and liquid_template_exists?(domain, controller, page)
    return name
  end

  def liquid_template_exists?(domain, controller, page)
    website = Website.find_by_name(domain)
    website = Website.find(:first) unless website
    plate = nil
    plate = website.layout(controller, page) if website
    !plate.blank?
  end
end
