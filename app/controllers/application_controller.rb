# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Clearance::Authentication
    
  before_filter [:authenticate, :admin?], :except => [:index, :show] if ENV["RAILS_ENV"] == 'production'
  before_filter :set_title, :set_crumbs
   
   LOCAL_IPS =/^127\.0\.0\.1$|^192\.231\.113\.|^192\.108\.190\.|^192\.108\.188\.|^192\.108\.191\./

   def trusted_ip?
     LOCAL_IPS =~ request.remote_ip
   end
  
   def admin?
     logger.info current_user.role
     current_user.try(:role) == 'admin'
   end
    
  private
  
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
