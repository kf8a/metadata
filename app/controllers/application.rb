# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authenticated
  before_filter :login_required, :except => [:index, :show]
  before_filter :set_title, :set_crumbs
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_metadata_session_id'
  
  Mime::Type.register "text/xml", :eml  

  Struct.new('Crumb', :url, :name)
  
  private
  
  def set_title
    @title = 'LTER KBS'
  end
  
  def set_crumbs
      @crumbs = []
  end
end
