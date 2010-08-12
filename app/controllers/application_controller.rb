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

  #TODO subdomain_fu returns the subdomain test during testing not sure if this in needed
  def site_layout
    if request_subdomain == 'test'
      'lter'
    else
      request_subdomain
    end
  end

  def request_subdomain(requested_subdomain=current_subdomain)
      current_subdomain  #|| 'lter'
  end

  def template_choose(page=action_name)
    liquid_name = "app/views/#{controller_name}/liquid_#{page}.html.erb"
    if File.file?(liquid_name)
      website = Website.find_by_name(request_subdomain)
      website = Website.find(:first) unless website
      @plate = nil
      @plate = website.layout(controller_name, page) if website
      return liquid_name if @plate
    end

    domain_file_name = "app/views/#{controller_name}/#{request_subdomain}_#{page}.html.erb"
    non_domain_file_name = "app/views/#{controller_name}/#{page}.html.erb"

    if File.file?(domain_file_name) then
      domain_file_name
    else
      non_domain_file_name
    end
  end

end
