# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authenticated
    
  before_filter :login_required, :except => [:index, :show] #if ENV["RAILS_ENV"] == 'production'
  before_filter :set_title, :set_crumbs
    
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_metadata_session_id'
  
  protected
   
   LOCAL_IPS =/^127\.0\.0\.1$|^192\.231\.113\.|^192\.108\.190\.|^192\.108\.188\.|^192\.108\.191\./

   def trusted_ip?
     LOCAL_IPS =~ request.remote_ip
   end
  
  private
  
  def set_title
    @title = 'LTER KBS'
  end
  
  def set_crumbs
    @crumbs = []
  end

end
