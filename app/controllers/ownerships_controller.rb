class OwnershipsController < ApplicationController

  before_filter :require_admin unless ENV["RAILS_ENV"] == 'development'

  def index
  end
  
  private
  
  def require_admin
    unless signed_in?
      flash[:notice] = "You must be signed in as an administrator in order to access this page"
      redirect_to sign_in_path
      return false
    end
    
    unless current_user.role == 'admin'
      flash[:notice] = "You must be signed in as an administrator in order to access this page"
      redirect_to sign_in_path
      return false
    end
  end
end
