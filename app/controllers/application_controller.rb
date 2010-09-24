# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Clearance::Authentication
    
  layout :site_layout

  #before_filter :admin?, :except => [:index, :show] unless ENV["RAILS_ENV"] == 'development'
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
    requested_subdomain = 'lter' unless ['lter','glbrc'].include?(requested_subdomain)
    return requested_subdomain
  end
  
  def render_subdomain(page=action_name, mycontroller=controller_name, domain=@subdomain_request)
    render_liquid(page, mycontroller, domain) or
    render_domain_specific(page, mycontroller, domain) or
    render :template => "#{mycontroller}/#{page}"
  end

  def render_liquid(page, mycontroller, domain)
    if liquid_file_exists?(mycontroller, page)
      if liquid_template_exists?(domain, mycontroller, page)
        render :template => "#{mycontroller}/liquid_#{page}"
      end
    end
  end

  def render_domain_specific(page, mycontroller, domain)
    if domain_specific_file_exists?(domain, mycontroller, page)
      render :template => "#{mycontroller}/#{domain}_#{page}"
    end
  end

  def liquid_file_exists?(mycontroller, page)
    base_name = "app/views/" + mycontroller + "/liquid_" + page
    erb_name  = base_name + ".html.erb"
    rhtml_name = base_name + ".rhtml"
    File.file?(erb_name) || File.file?(rhtml_name)
  end

  def liquid_template_exists?(domain, mycontroller, page)
    website = Website.find_by_name(domain)
    website = Website.find(:first) unless website
    plate = website.try(:layout, mycontroller, page)
    !plate.blank?
  end

  def domain_specific_file_exists?(domain, mycontroller, page)
    base_name = "app/views/"+ mycontroller + "/"  + domain + "_" + page
    erb_name = base_name + ".html.erb"
    rhtml_name = base_name + ".rhtml"
    File.file?(erb_name) || File.file?(rhtml_name)
  end
end
