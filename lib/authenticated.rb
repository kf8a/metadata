module Authenticated
  protected
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default
    session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
    session[:return_to] = nil
  end
  
  def login_required
    session[:user_id]  ? true : access_denied
  end
  
  def logged_in?
    if RAILS_ENV['production']
      session[:user_id] != nil
    else
      true
    end
  end
  
  def logout
    session[:user_id] = nil
  end
  
  def login(user_id)
    session[:user_id] = user_id
  end
  
  def access_denied
    respond_to do |accepts|
      accepts.html do
        redirect_to :controller => 'sessions', :action => 'new'
      end
      accepts.xml do
        headers["Status"] = "Unauthorized"
        render :text => "Could't authenticate you", :status => '401 Unauthorized'
      end
    end
    false
  end
  
  def self.included(base)
    base.send :helper_method, :logged_in?
  end
end