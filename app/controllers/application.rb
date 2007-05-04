# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authenticated
  before_filter :login_required, :except => [:index, :show]
  before_filter :set_title
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_metadata_session_id'
  
  Mime::Type.register "text/xml", :eml  
  
  private
  def set_title
    @title = 'LTER KBS'
  end
end
