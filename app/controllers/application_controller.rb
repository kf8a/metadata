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
      logger_info current_user
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
     current_subdomain == 'glbrc' ? "glbrc" : "lter"
  end
  
   
end
