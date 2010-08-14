class OwnershipsController < ApplicationController

  before_filter :require_admin unless ENV["RAILS_ENV"] == 'development'

  def index
  end
  
  def show
    get_datatable
  end
  
  def new
    @datatable = Datatable.find(params[:datatable]) if params[:datatable]
    @datatables = Datatable.all unless @datatable
    @users = User.all
    @ownership = Ownership.new
  end
  
  def create
    user = User.find(params[:user])
    datatable = Datatable.find(params[:datatable])
    ownership = Ownership.new(:user => user, :datatable => datatable)
    respond_to do |format|
      if ownership.save
        flash[:notice] = 'Ownership has been granted to ' + user.email
        format.html { redirect_to ownership_path(datatable) }
        format.xml  { head :created, :location => ownership_path(datatable) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => ownership.errors.to_xml }
      end
    end
  end
  
  def destroy
    user = User.find(params[:user])
    datatable = Datatable.find(params[:datatable])
    ownerships = Ownership.find_all_by_user_id_and_datatable_id(user, datatable)
    ownerships.each do |ownership|
      ownership.destroy
    end

    respond_to do |format|
      flash[:notice] = 'Ownership has been revoked from ' + user.email
      format.html { redirect_to ownership_path(datatable) }
      format.xml  { head :ok }
    end
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
