class PermissionsController < ApplicationController

  before_filter :require_owner, :require_datatable, :except => [:index] unless ENV["RAILS_ENV"] == 'development'
  
  def index
  
  end
  
  def show
  
  end
  
  def new
  
  end
  
  private
  
  def require_datatable
    datatable = Datatable.find(params[:datatable])
    unless datatable
      flash[:notice] = "You must select a valid datatable to grant permissions"
      redirect_to :action => :index
      return false
    end
  end

  def require_owner
    unless current_user.owns(params[:datatable])
      flash[:notice] = "You must be the owner of the datatable in order to access this page"
      redirect_to :action => :index
      return false
    end
  end
end
