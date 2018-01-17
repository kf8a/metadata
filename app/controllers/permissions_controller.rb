# add and remove permissions for datatables
class PermissionsController < ApplicationController
  before_action :require_login, except: [:index]
  before_action :require_datatable, :require_owner, except: [:index]

  def index
    @datatables = current_user.try(:datatables)
  end

  def show
    owner = current_user
    @permissions = Permission.where(owner_id: owner.id, datatable_id: @datatable.id)
    @permitted_users = @permissions.permitted_users
  end

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    flash[:notice] = 'No user with that email' unless user
    permission = my_permission(user, current_user, @datatable) || Permission.new
    permission.datatable_id = @datatable.id
    permission.user = user
    permission.owner = current_user
    permission.decision = 'approved'

    respond_to do |format|
      if permission.save
        flash[:notice] = "Permission has been granted to #{user}"
        format.html { redirect_to permission_path(@datatable.id) }
        format.xml  { head :created, location: permission_path(@datatable.id) }
      else
        format.html { render 'new' }
        format.xml  { render xml: permission.errors.to_xml }
      end
    end
  end

  def destroy
    user = User.find(params[:user])
    owner = current_user
    permissions = my_permissions(user, owner, @datatable)
    permissions.each(&:destroy)

    respond_to do |format|
      flash[:notice] = 'Permission has been revoked from ' + user.email
      format.html { redirect_to permission_path(@datatable) }
      format.xml  { head :ok }
    end
  end

  def deny
    user = User.find_by(email: params[:email])
    owner = current_user
    permission = my_permission(user, owner, @datatable)
    if permission
      permission.decision = 'denied'
    else
      permission = new_denied_permission(user, owner, @datatable)
    end

    permission.save
    respond_to do |format|
      flash[:notice] = 'Permission has been denied for ' + user.email
      format.html { redirect_to permission_path(@datatable) }
      format.xml { head :ok }
    end
  end

  private

  def my_permissions(user, owner, datatable)
    Permission.where(user_id: user.id,
                     datatable_id: datatable.id,
                     owner_id: owner.id)
  end

  def my_permission(user, owner, datatable)
    Permission.find_by(user_id: user,
                       datatable_id: datatable,
                       owner_id: owner)
  end

  def new_denied_permission(user, owner, datatable)
    Permission.new(user: user,
                   datatable: datatable,
                   owner: owner,
                   decision: 'denied')
  end

  def require_datatable
    @datatable = Datatable.find(params[:id]) if params[:id]
    unless @datatable
      @datatable = Datatable.find(params[:datatable]) if params[:datatable]
    end
    unless @datatable
      flash[:notice] = 'You must select a valid datatable to grant permissions'
      redirect_to action: :index
      false
    end
  end

  def require_owner
    return if current_user.try(:owns?, @datatable)

    flash[:notice] = 'You must be signed in as the owner of'\
      ' the datatable in order to access this page'
    redirect_to action: :index
    false
  end
end
