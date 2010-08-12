class OwnershipsController < ApplicationController

  before_filter :require_admin unless ENV["RAILS_ENV"] == 'development'

  def index
  end
  
  def show
    get_datatable
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
  
  def get_datatable
    @datatable = Datatable.find(params[:id]) if params[:id]
    @datatable = Datatable.find(params[:datatable]) if params[:datatable]
    unless @datatable
      flash[:notice] = "You must select a valid datatable to grant permissions"
      redirect_to :action => :index
      return false
    end
  end
end
