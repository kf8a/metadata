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

#Takes care of choosing templates
class TemplateHandler
  def initialize(page, mycontroller, domain)
    @page = page
    @mycontroller = mycontroller
    @domain = domain
  end

  def correct_template
    self.render_liquid or self.render_domain_specific or self.render_default
  end

  #renders pages like "uploads/liquid_index"
  def render_liquid
    if self.liquid_file_exists? && self.liquid_template_exists?
      "#{@mycontroller}/liquid_#{@page}"
    end
  end

  #renders pages like "uploads/glbrc_index"
  def render_domain_specific
    "#{@mycontroller}/#{@domain}_#{@page}" if self.domain_specific_file_exists?
  end

  #renders pages like "uploads/index"
  def render_default
    "#{@mycontroller}/#{@page}"
  end

  def liquid_file_exists?
    base_name = "app/views/" + @mycontroller + "/liquid_" + @page
    erb_name  = base_name + ".html.erb"
    rhtml_name = base_name + ".rhtml"
    File.file?(erb_name) || File.file?(rhtml_name)
  end

  def liquid_template_exists?
    website = Website.find_by_name(@domain)
    website ||= Website.find(:first)
    plate = website.try(:layout, @mycontroller, @page)
    !plate.blank?
  end

  def domain_specific_file_exists?
    base_name = "app/views/"+ @mycontroller + "/"  + @domain + "_" + @page
    erb_name = base_name + ".html.erb"
    rhtml_name = base_name + ".rhtml"
    File.file?(erb_name) || File.file?(rhtml_name)
  end

end
