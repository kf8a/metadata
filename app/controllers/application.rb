# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

Struct.new('Crumb', :url, :name)
class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include Authenticated
  
  consider_local "207.73.114.153"
  
  before_filter :login_required, :except => [:index, :show]
  before_filter :set_title, :set_crumbs
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_metadata_session_id'
  
  Mime::Type.register "text/xml", :eml  
  
  protected
   def local_request? #:doc:
    [request.remote_addr, request.remote_ip] == ["127.0.0.1","207.73.114.153"] * 2
  end
  
  private
  
  def set_title
    @title = 'LTER KBS'
  end
  
  def set_crumbs
      @crumbs = []
  end
end
