# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Clearance::Authentication
    
  before_filter :authenticate, :except => [:index, :show] unless ENV["RAILS_ENV"] == 'development'
  before_filter :set_title, :set_crumbs
   
   LOCAL_IPS =/^127\.0\.0\.1$|^192\.231\.113\.|^192\.108\.190\.|^192\.108\.188\.|^192\.108\.191\./

   def trusted_ip?
     LOCAL_IPS =~ request.remote_ip
   end
      
  private
  
  def admin?
    if signed_in?
      unless current_user.try(:role) == 'admin'
        deny_access
      end
    end
  end
  
  def set_title
    @title = 'LTER KBS'
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
    file_name = "app/views/" + controller + "/" + domain + "_" + page + ".html.erb"
    if File.file?(file_name)
      return file_name
    else
      non_domain_file_name = "app/views/" + controller + "/" + page + ".html.erb"
      return non_domain_file_name
    end
  end
   
end
