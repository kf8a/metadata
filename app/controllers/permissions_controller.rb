class PermissionsController < ApplicationController

  before_filter :require_datatable, :require_owner, :except => [:index] 
  
  def index
    @datatables = current_user.try(:datatables)
  end
  
  def show
    owner = current_user
    @permissions = Permission.where(:owner_id => owner.id, :datatable_id => @datatable.id)
    @permitted_users = @permissions.permitted_users
  end
  
  def new
  end
  
  def create
    user = User.find_by_email(params[:email])
    flash[:notice] = 'No user with that email' unless user
    owner = current_user
    permission = Permission.find_by_user_id_and_datatable_id_and_owner_id(user, @datatable, owner)
    if permission
      permission.decision = "approved"
    else
      permission = Permission.new(:user => user, :datatable => @datatable, :owner => owner, :decision => "approved")
    end

    respond_to do |format|
      if permission.save
        flash[:notice] = 'Permission has been granted to ' + user.email
        format.html { redirect_to permission_path(@datatable.id) }
        format.xml  { head :created, :location => permission_path(@datatable.id) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => permission.errors.to_xml }
      end
    end
  end
  
  def destroy
    user = User.find(params[:user])
    owner = current_user
    permissions = Permission.find_all_by_user_id_and_datatable_id_and_owner_id(user.id, @datatable.id, owner.id)
    permissions.each do |permission|
      permission.destroy
    end

    respond_to do |format|
      flash[:notice] = 'Permission has been revoked from ' + user.email
      format.html { redirect_to permission_path(@datatable) }
      format.xml  { head :ok }
    end
  end
  
  def deny
    user = User.find_by_email(params[:email])
    owner = current_user
    permission = Permission.find_by_user_id_and_datatable_id_and_owner_id(user, @datatable, owner)
    if permission
      permission.decision = "denied"
    else
      permission = Permission.new(:user => user, :datatable => @datatable, :owner => owner, :decision => "denied")
    end

    permission.save
    respond_to do |format|
      flash[:notice] = 'Permission has been denied for ' + user.email
      format.html { redirect_to permission_path(@datatable) }
      format.xml { head :ok }
    end
  end
  
  private
  
  def require_datatable
    @datatable = Datatable.find(params[:id]) if params[:id]
    @datatable = Datatable.find(params[:datatable]) if params[:datatable]
    unless @datatable
      flash[:notice] = "You must select a valid datatable to grant permissions"
      redirect_to :action => :index
      return false
    end
  end

  def require_owner
    unless current_user.try(:owns?, @datatable)
      flash[:notice] = "You must be signed in as the owner of the datatable in order to access this page"
      redirect_to :action => :index
      return false
    end
  end
end
